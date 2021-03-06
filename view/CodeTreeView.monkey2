
Namespace ted2go


Class CodeTreeView Extends TreeViewExt
	
	Field SortByType:=True
	Field ShowInherited:=False
	
	Method Fill( fileType:String,path:String,expandIfOnlyOneItem:Bool=True )
	
		Local stack:=New Stack<TreeView.Node>
		Local parser:=ParsersManager.Get( fileType )
		Local node:=RootNode
		
		RootNodeVisible=False
		node.Expanded=True
		node.RemoveAllChildren()
		
		_stack.Clear()
		
		' extract all items in file
		Local list:=parser.ItemsMap[path]
		If list Then _stack.AddAll( list )
		
		' extensions are here too
		For Local lst:=Eachin parser.ExtraItemsMap.Values.All()
			For Local i:=Eachin lst
				If i.FilePath=path
					If Not _stack.Contains( i.Parent ) Then _stack.Add( i.Parent )
				Endif
			Next
		Next
		
		If _stack.Empty Return
		
		' sorting
		SortItems( _stack )
		
		For Local i:=Eachin _stack
			AddTreeItem( i,node,parser )
		Next
		
		If expandIfOnlyOneItem And RootNode.NumChildren=1
			RootNode.Children[0].Expanded=True
		Endif
		
	End
	
	Method SelectByScope( scope:CodeItem )
		
		Local node:=FindNode( RootNode,scope )
		If Not node Return
		
		node.Expanded=True
		TreeViewExpander.ExpandParents( node )
		
		MeasureLayoutSize()
		
		Selected=Null
		Selected=node
	End
	
	
	Private
	
	Field _stack:=New Stack<CodeItem>
	
	Method FindNode:TreeView.Node( treeNode:TreeView.Node,item:CodeItem )
	
		Local node:=Cast<CodeTreeNode>( treeNode )
		
		If node And node.CodeItem = item Return node
	
		Local list:=treeNode.Children
		If Not list Return Null
		
		For Local i:=Eachin list
			Local n:=FindNode( i,item )
			If n Return n
		Next
	
		Return Null
	End
	
	Method AddTreeItem( item:CodeItem,node:TreeView.Node,parser:ICodeParser )
	
		Local n:=New CodeTreeNode( item,node )
		
		' restore expand state
		_expander.Restore( n )
		
		If item.Children = Null And Not ShowInherited Return
		
		Local list:=New Stack<CodeItem>
		
		If item.Children<>Null Then list.AddAll( item.Children )
		
		Local inherRoot:CodeItem=Null
		
		' sorting only root class members
		If item.IsLikeClass
				
			SortItems( list )
			
			If ShowInherited
				Local lst:=New Stack<CodeItem>
				GetInherited( item,parser,lst )
				If lst<>Null And Not lst.Empty
					inherRoot=New CodeItem( "[ Inherited members ]" )
					inherRoot.Children=lst
					inherRoot.KindStr="inherited"
					list.Insert( 0,inherRoot )
					'For Local i:=Eachin lst
					'	Local children:=i.Children
					'	
					'Next
				Endif
			Endif
		End
		
		If list.Empty Return
		
		Local added:=New StringStack
		For Local i:=Eachin list
			If i.Kind = CodeItemKind.Param_ Continue
			Local txt:=i.Text
			If added.Contains( txt ) Continue
			added.Add( txt )
			AddTreeItem( i,n,parser )
		End
		
	End
	
	Method SortItems( list:Stack<CodeItem> )
	
		If SortByType
			CodeItemsSorter.SortByType( list,False,True )
		Else
			CodeItemsSorter.SortByPosition( list )
		End
	End
	
	Method GetInherited:Stack<CodeItem>( item:CodeItem,parser:ICodeParser,result:Stack<CodeItem> )
	
		If item.SuperTypesStr=Null Return Null
	
		For Local t:=Eachin item.SuperTypesStr
			Local sup:=parser.GetItem( t )
			If Not sup Continue
			If sup.Children<>Null
				Local it:=New CodeItem( t )
				it.KindStr=sup.KindStr
				it.Children=sup.Children
				result.Add( it )
				'Local list:=New List<CodeItem>
				'For Local child:=Eachin sup.Children
					' grab some properties
					'it=New CodeItem( child.Ident)
					'it.KindStr=child.KindStr
					'it.Type=child.Type
					'it.FilePath=child.FilePath
					'it.ScopeStartPos=child.ScopeStartPos
					
				'Next
			Endif
			If sup.IsLikeClass Then GetInherited( sup,parser,result )
		Next
		Return result
	End
End


Class CodeTreeNode Extends TreeView.Node

	Method New( item:CodeItem,node:TreeView.Node )
		
		Super.New( item.Text,node )
		_code=item
		Icon=CodeItemIcons.GetIcon( item )
	End
	
	Property CodeItem:CodeItem()
		
		Return _code
	End
	
	
	Private
	
	Field _code:CodeItem
	
End
