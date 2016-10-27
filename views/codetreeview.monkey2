
Namespace ted2go



Class CodeTreeView Extends TreeViewExt
	
	Field SortEnabled:Bool
	
	Method Fill( fileType:String,path:String )
	
		StoreTreeExpands()
		
		Local stack:=New Stack<TreeView.Node>
		Local parser:=ParsersManager.Get( fileType )
		Local node:=RootNode
		
		RootNodeVisible=False
		node.Expanded=True
		node.RemoveAllChildren()
		
		Local list:=parser.ItemsMap[path]
		If list = Null Return
		
		' sorting
		SortItems( list )
		
		For Local i:=Eachin list
			AddTreeItem( i,node,parser )
		Next
		
	End
	
	
	Private
	
	Field _expands:=New StringMap<Bool>
	Method StoreTreeExpands()
	
		_expands.Clear()
		StoreNodeExpand( RootNode )
		
	End
	
	Method StoreNodeExpand( node:TreeView.Node )
		
		If Not node.Expanded Return
		
		Local key:=GetNodePath( node )
		_expands[key]=node.Expanded
		
		If node.Children = Null Return
		
		For Local i:=Eachin node.Children
			StoreNodeExpand( i )
		Next
		
	End
	
	Method RestoreNodeExpand( node:TreeView.Node )
	
		Local key:=GetNodePath( node )
		node.Expanded=_expands[key]
		
	End
	
	Method GetNodePath:String( node:TreeView.Node )
	
		Local s:=node.Text
		Local i:=node.Parent
		While i <> Null
			s=i.Text+"\"+s
			i=i.Parent
		Wend
		Return s
		
	End
		
	Method AddTreeItem( item:CodeItem,node:TreeView.Node,parser:ICodeParser )
	
		parser.RefineRawType( item ) 'refine all visible items
		
		Local n:=New CodeTreeNode( item,node )
		
		' restore expand state
		RestoreNodeExpand( n )
		
		If item.Children = Null Return
		
		' sorting only root class members
		Select item.Kind
			Case CodeItemKind.Class_,CodeItemKind.Struct_,CodeItemKind.Enum_
				SortItems( item.Children )
		End
		
		For Local i:=Eachin item.Children
			AddTreeItem( i,n,parser )
		End
				
	End
	
	Field _sorterByName:Int( lhs:CodeItem,rhs:CodeItem )
	Field _sorter:Int( lhs:CodeItem,rhs:CodeItem )
	
	Method SortItems( list:List<CodeItem> )
	
		If Not SortEnabled Return
	
		If _sorterByName = Null
			_sorterByName=Lambda:Int( lhs:CodeItem,rhs:CodeItem )
				' here we can sort by name / access / and so on
				Return lhs.Text <=> rhs.Text
			End
		Endif
		_sorter=_sorterByName
		' sorting
		list.Sort(_sorter)
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
