
#rem

A slightly more complicated window example.

The example implements a resizable window with virtual resolution support via the "letterbox" and "stretch" layout modes, and shows
some simple keyboard/mouse event handling.

#end

Namespace test

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Class MyWindow Extends Window

	Field virtualRes:=New Vec2i( 320,240 )

	Method New( title:String,width:Int,height:Int,flags:WindowFlags=WindowFlags.Resizable )
	
		'Call super class constructor
		'
		Super.New( title,width,height,flags )
		
		'Set initial layout (this is the default for Windows).
		'
		Layout="fill"
		

		'Window clear color - for "letterbox" and "float" layouts, this is effectively the border color.
		'
		ClearColor=Color.Black
		
		
		'Set minimum view size
		'
		MinSize=New Vec2i( 200,140 )

		
		'Set view background color.
		'
		Style.BackgroundColor=Color.DarkGrey
		
		
		'One way to detect window resizing (you can also override OnWindowEvent).
		'
		'Note: you don't have to use a lambda here, a method or function will also work fine.
		'
		WindowResized=Lambda()
		
			Print "Window Resized to:"+Frame.Width+","+Frame.Height
			
		End
		
		
		'One way to detect window close click (you can also override OnWindowEvent).
		'
		'Note: WindowClose is connected to App.Terminate by default, so this doesn't do a lot.
		'
		WindowClose=Lambda()
		
			Print "WindowClose - outta here!"
			
			App.Terminate()
		End
	
	End

	Method OnRender( canvas:Canvas ) Override
	
		'This is necessary for 'continuous' rendering.
		'
		'Without it, OnRender will only be called when necessary, eg: when window is resized.
		'
		App.RequestRender()
		
		
		'Get mouse location in 'view' coordinates.
		'
		'Note: this is only necessary if Layout is not "fill". If Layout="fill" (the default), you can just use App.MouseLocation directly.
		'
		Local mouse:=TransformPointFromView( App.MouseLocation,Null )


		'Render!
		'		
		Local h:=canvas.Font.Height
		
		canvas.DrawText( "Size="+Rect.Size.ToString(),0,0 )
		canvas.DrawText( "Mouse="+mouse.ToString(),0,h )
		canvas.DrawText( "Layout=~q"+Layout+"~q  ('L' to cycle)",0,h*2 )
		
		If Layout="float"
			canvas.DrawText( "Resolution="+virtualRes.ToString()+"  ('R' to cycle)",0,h*3 )
			canvas.DrawText( "Gravity="+Gravity.ToString()+"  ('G' to cycle)",0,h*4 )
		Else If Layout="letterbox"
			canvas.DrawText( "Resolution="+virtualRes.ToString()+"  ('R' to cycle)",0,h*3 )
			canvas.DrawText( "Gravity="+Gravity.ToString()+"  ('G' to cycle)",0,h*4 )
		Else If Layout="stretch"
			canvas.DrawText( "Resolution="+virtualRes.ToString()+"  ('R' to cycle)",0,h*3 )
		Endif
		
		canvas.DrawText( "Hello World!",Width/2,Height/2,.5,.5 )
	End
	
	'Measured out view.
	'
	'This is used by the "float", "letterbox" and "stretch" layouts.
	'
	Method OnMeasure:Vec2i() Override
	
		Return virtualRes
	End
	
	'Process a KeyEvent.
	'
	'Needed because there's no App.KeyHit yet!
	'
	Method OnKeyEvent( event:KeyEvent ) Override
	
		Select event.Type
		Case EventType.KeyDown
			Select event.Key
			Case Key.L
				CycleLayout()
			Case Key.G
				CycleGravity()
			Case Key.R
				CycleVirtualRes()
			End
		End
		
	End
	
	'Process a MouseEvent.
	'
	'Note: event.Location property is in 'view space' coordinates.
	'
	Method OnMouseEvent( event:MouseEvent ) Override
	End
	
	Method CycleLayout()
		Select Layout
		Case "fill"
			Layout="letterbox"
		Case "letterbox"
			Layout="stretch"
		Case "stretch"
			Layout="float"
		Case "float"
			Layout="fill"
		End
		virtualRes=New Vec2i( 320,240 )
		Gravity=New Vec2f( .5,.5 )
	End
	
	Method CycleGravity()
		Local gravity:=Gravity
		gravity.x+=.5
		If gravity.x>1
			gravity.x=0
			gravity.y+=.5
			If gravity.y>1 gravity.y=0
		Endif
		Gravity=gravity
	End
	
	Method CycleVirtualRes()
		Select virtualRes.x
		Case 320
			virtualRes=New Vec2i( 640,480 )		'4:3
		Case 640
			virtualRes=New Vec2i( 1024,768 )	'4:3
		Case 1024
			virtualRes=New Vec2i( 1280,720 )	'16:9
		Case 1280
			virtualRes=New Vec2i( 1920,1080 )	'16:9
		Case 1920
			virtualRes=New Vec2i( 320,240 )		'4:3
		End
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow( "Simple Window Demo!",640,512 )
	
	App.Run()
End
