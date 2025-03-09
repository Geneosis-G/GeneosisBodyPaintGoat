class BodyPaintGoat extends GGMutator;

/**
 * if the mutator should be selectable in the Custom Game Menu.
 */
static function bool IsUnlocked( optional out array<AchievementDetails> out_CachedAchievements )
{
	return True;
}

/**
 * See super.
 */
function ModifyPlayer(Pawn Other)
{
	local GGGoat goat;
	local GGMutatorComponent mutComp;

	goat = GGGoat( other );

	if( goat != none )
	{
		if( IsValidForPlayer( goat ) )
		{
			mutComp = new default.mMutatorComponentClass;
			mutComp.AttachToPlayer( goat, self );
		}
	}
	
	super.ModifyPlayer( other );
}

DefaultProperties
{
	mMutatorComponentClass=class'BodyPaintGoatComponent'
}