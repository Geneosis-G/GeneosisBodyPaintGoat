class BodyPaintGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var float bodyPaintTimer;

var PostProcessChain celShader;
var array< PostProcessChain > oldPPChains;
var float celShadingTimer;
var bool isCelShading;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);
	
	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;
		
		GGPlayerInput( PlayerController( gMe.Controller ).PlayerInput ).RegisterKeyDownListener( KeyDown );
		GGPlayerInput( PlayerController( gMe.Controller ).PlayerInput ).RegisterKeyUpListener( KeyUp );
	}
}

function KeyDown( name newKey )
{
	local GGPlayerInputGame localInput;

	localInput = GGPlayerInputGame( PlayerController( gMe.Controller ).PlayerInput );
	
	if( localInput.IsKeyIsPressed( "GBA_ToggleRagdoll", string( newKey ) ) )
	{
		gMe.SetTimer( celShadingTimer, false, NameOf( SwitchCelShading ), self);
	}
	
	if( localInput.IsKeyIsPressed( "GBA_AbilityBite", string( newKey ) ) )
	{
		gMe.SetTimer( bodyPaintTimer, false, NameOf( PaintBody ), self);
	}
}

function KeyUp( name newKey )
{
	local GGPlayerInputGame localInput;

	localInput = GGPlayerInputGame( PlayerController( gMe.Controller ).PlayerInput );

	if( localInput.IsKeyIsPressed( "GBA_ToggleRagdoll", string( newKey ) ) )
	{
		if(gMe.IsTimerActive(NameOf( SwitchCelShading ), self))
		{
			gMe.ClearTimer(NameOf( SwitchCelShading ), self);
		}
	}
	
	if( localInput.IsKeyIsPressed( "GBA_AbilityBite", string( newKey ) ) )
	{
		if(gMe.IsTimerActive(NameOf( PaintBody ), self))
		{
			gMe.ClearTimer(NameOf( PaintBody ), self);
		}
	}
}

function PaintBody()
{
	local GGPawn grabbedPawn;
	local DynamicSMActor grabbedSMA;
	local array<MaterialInterface> paintings;
	local MaterialInterface painting;
	local int index;
	
	if(gMe.mGrabbedItem == none)
	{
		return;
	}
	
	grabbedPawn = GGPawn(gMe.mGrabbedItem);
	grabbedSMA = DynamicSMActor(gMe.mGrabbedItem);
	
	if(grabbedPawn != none)
	{
		paintings=grabbedPawn.Mesh.Materials;
	}
	else if(grabbedSMA != none)
	{
		paintings=grabbedSMA.StaticMeshComponent.Materials;
	}
	
	foreach paintings(painting, index)
	{
		gMe.Mesh.SetMaterial(index, painting);
	}
}

function StartCelShading()
{
	local int i;
	local GGLocalPlayer goatPlayer;

	goatPlayer = gMe.GetLocalPlayerGoat();

	for( i = 0; i < goatPlayer.PlayerPostProcessChains.Length; ++i )
	{
		oldPPChains.AddItem( goatPlayer.PlayerPostProcessChains[ i ] );
	}

	goatPlayer.RemoveAllPostProcessingChains();

	if( goatPlayer.InsertPostProcessingChain( celShader, 0, false ) )
	{
		goatPlayer.TouchPlayerPostProcessChain();
	}
}

function StopCelShading()
{
	local int i;
	local GGLocalPlayer goatPlayer;

	goatPlayer = gMe.GetLocalPlayerGoat();
	goatPlayer.RemoveAllPostProcessingChains();

	for( i = 0; i < oldPPChains.Length; ++i )
	{
		goatPlayer.InsertPostProcessingChain( oldPPChains[ i ], -1, false );
	}
	oldPPChains.Length=0;
}

function SwitchCelShading()
{
	isCelShading = !isCelShading;

	if(isCelShading)
	{
		StartCelShading();
	}
	else
	{
		StopCelShading();
	}
}

defaultproperties
{
	//celShader=PostProcessChain'SobelEdgeContent.SobelEdgePostProcess'
	
	celShadingTimer=5.f
	bodyPaintTimer=2.f
}