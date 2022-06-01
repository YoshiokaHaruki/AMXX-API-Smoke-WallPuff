public stock const PluginName[ ] =			"[API] Addon: Smoke WallPuff";
public stock const PluginVersion[ ] =		"1.1.1";
public stock const PluginAuthor[ ] =		"Yoshioka Haruki";

/* ~ [ Includes ] ~ */
#include <amxmodx>
#include <fakemeta_util>
#include <reapi>

#if !defined _reapi_included
	#include <hamsandwich>

	#define NULLENT							FM_NULLENT
	#define PDATA_SAFE						2

	#define get_entvar						pev
	#define set_entvar						set_pev

	#define var_classname					pev_classname
	#define var_impulse						pev_impulse
	#define var_movetype					pev_movetype
	#define var_frame						pev_frame
	#define var_framerate					pev_framerate
	#define var_rendermode					pev_rendermode
	#define var_rendercolor					pev_rendercolor
	#define var_renderamt					pev_renderamt
	#define var_scale						pev_scale
	#define var_velocity					pev_velocity
	#define var_origin						pev_origin
	#define var_nextthink					pev_nextthink
	#define var_yaw_speed					pev_yaw_speed
	#define var_pitch_speed					pev_pitch_speed
	#define var_flags						pev_flags

	#define rg_create_entity				fm_create_entity
	#define is_nullent(%0)					( %0 == NULLENT || pev_valid( %0 ) != PDATA_SAFE )
#endif

/* ~ [ Plugin Settings ] ~ */
new const EntityWallPuffReference[ ] =		"env_sprite";
new const EntityWallPuffClassname[ ] =		"ent_smokepuff_x";
new const EntityWallPuffSprites[ ][ ] = {
	"sprites/wall_puff1.spr",
	"sprites/wall_puff2.spr",
	"sprites/wall_puff3.spr",
	"sprites/wall_puff4.spr"
};

/* ~ [ Params ] ~ */
new gl_iszAllocString_SmokeKey;

/* ~ [ Macroses ] ~ */
#define Vector3(%0)							Float: %0[ 3 ]

#define var_max_frame						var_yaw_speed // CEntity: env_sprite
#define var_last_time						var_pitch_speed // CEntity: env_sprite

/* ~ [ AMX Mod X ] ~ */
public plugin_natives( ) register_native( "zc_smoke_wallpuff_draw", "native_smoke_wallpuff_draw" );
public plugin_precache( )
{
	/* -> Precache Models -> */
	for ( new iFile = 0; iFile < sizeof EntityWallPuffSprites; iFile++ )
		engfunc( EngFunc_PrecacheModel, EntityWallPuffSprites[ iFile ] );

	/* -> Alloc String -> */
	gl_iszAllocString_SmokeKey = engfunc( EngFunc_AllocString, EntityWallPuffClassname );
}

public plugin_init( )
{
	register_plugin( PluginName, PluginVersion, PluginAuthor );

	#if defined _reapi_included
		/* -> ReAPI -> */
		RegisterHookChain( RG_CSGameRules_CleanUpMap, "RG_CSGameRules__CleanUpMap_Post", true );
	#else
		/* -> Events -> */
		register_event( "HLTV", "EV_RoundStart", "a", "1=0", "2=0" );

		/* -> HamSandwich -> */
		RegisterHam( Ham_Think, EntityWallPuffReference, "CSmokeWallPuff__Think", false );
	#endif
}

#if defined _reapi_included
	/* ~ [ ReAPI ] ~ */
	public RG_CSGameRules__CleanUpMap_Post( )
#else
	/* ~ [ Events ] ~ */
	public EV_RoundStart( )
#endif
	{
		new pEntity = NULLENT;
		while ( ( pEntity = fm_find_ent_by_class( pEntity, EntityWallPuffClassname ) ) > 0 )
			UTIL_KillEntity( pEntity );
	}

/* ~ [ Other ] ~ */
CSmokeWallPuff__SpawnEntity( const Vector3( vecEnd ), const Vector3( vecPlaneNormal ), const Float: flScale = 0.5, const Float: flColor[ 3 ] = { 40.0, 40.0, 40.0 } ) 
{
	static const LOWER_LIMIT_OF_ENTITIES = 100;

	static iMaxEntities; if ( !iMaxEntities ) iMaxEntities = global_get( glb_maxEntities );
	if ( iMaxEntities - engfunc( EngFunc_NumberOfEntities ) <= LOWER_LIMIT_OF_ENTITIES )
		return NULLENT;

	static pSprite; pSprite = rg_create_entity( EntityWallPuffReference );
	if ( is_nullent( pSprite ) )
		return NULLENT;

	static Float: flGameTime; flGameTime = get_gametime( );
	static Vector3( vecEndPos ); xs_vec_add_scaled( vecEnd, vecPlaneNormal, 3.0, vecEndPos );
	static Vector3( vecDirectory ); xs_vec_mul_scalar( vecPlaneNormal, random_float( 25.0, 30.0 ), vecDirectory );

	set_entvar( pSprite, var_classname, EntityWallPuffClassname );
	set_entvar( pSprite, var_impulse, gl_iszAllocString_SmokeKey );
	set_entvar( pSprite, var_movetype, MOVETYPE_NOCLIP );

	set_entvar( pSprite, var_framerate, 30.0 );
	
	set_entvar( pSprite, var_rendermode, kRenderTransAdd );
	set_entvar( pSprite, var_rendercolor, flColor );
	set_entvar( pSprite, var_renderamt, random_float( 100.0, 180.0 ) );

	set_entvar( pSprite, var_scale, flScale );
	set_entvar( pSprite, var_velocity, vecDirectory );
	set_entvar( pSprite, var_origin, vecEndPos );

	set_entvar( pSprite, var_last_time, flGameTime );
	set_entvar( pSprite, var_nextthink, flGameTime );

	static iSpritesCount; if ( !iSpritesCount ) iSpritesCount = sizeof EntityWallPuffSprites;
	engfunc( EngFunc_SetModel, pSprite, EntityWallPuffSprites[ random( iSpritesCount ) ] );

	#if defined _reapi_included
		SetThink( pSprite, "CSmokeWallPuff__Think" );
	#endif

	return pSprite;
}

public CSmokeWallPuff__Think( const pSprite )
{
	#if !defined _reapi_included
		if ( is_nullent( pSprite ) || get_entvar( pSprite, var_impulse ) != gl_iszAllocString_SmokeKey )
			return;
	#endif

	static Float: flGameTime; flGameTime = get_gametime( );
	static Float: flFrame, Float: flFrameRate, Float: flLastTime; 

	#if defined _reapi_included
		flFrame = get_entvar( pSprite, var_frame );
		flFrameRate = get_entvar( pSprite, var_framerate );
		flLastTime = get_entvar( pSprite, var_last_time );
	#else
		get_entvar( pSprite, var_frame, flFrame );
		get_entvar( pSprite, var_framerate, flFrameRate );
		get_entvar( pSprite, var_last_time, flLastTime );
	#endif

	flFrame += ( flFrameRate * ( flGameTime - flLastTime ) );
	set_entvar( pSprite, var_frame, flFrame );

	if ( flFrame >= flFrameRate ) 
	{
		UTIL_KillEntity( pSprite );
		return;
	}

	static Vector3( vecVelocity ); get_entvar( pSprite, var_velocity, vecVelocity );
	if ( flFrame > 7.0 ) 
	{
		xs_vec_mul_scalar( vecVelocity, 0.97, vecVelocity );
		vecVelocity[ 2 ] += 0.7;

		if ( vecVelocity[ 2 ] > 70.0 ) vecVelocity[ 2 ] = 70.0;
	}

	if ( flFrame > 6.0 ) 
	{
		static bool: bDirection[ 2 ] = { true, true };
		static Float: flMagnitude[ 2 ];

		for ( new i; i < 2; i++ ) 
		{
			flMagnitude[ i ] += 0.075;
			if ( flMagnitude[ i ] > 5.0 ) flMagnitude[ i ] = 5.0;

			if ( bDirection[ i ] ) vecVelocity[ i ] += flMagnitude[ i ];
			else vecVelocity[ i ] -= flMagnitude[ i ];

			if ( !random_num( 0, 10 ) && flMagnitude[ i ] > 3.0 ) 
			{
				flMagnitude[ i ] = 0.0;
				bDirection[ i ] = !bDirection[ i ];
			}
		}
	}

	set_entvar( pSprite, var_velocity, vecVelocity );
	set_entvar( pSprite, var_last_time, flGameTime );
	set_entvar( pSprite, var_nextthink, flGameTime + 0.05 );
}

/* ~ [ Natives ] ~ */
public native_smoke_wallpuff_draw( const iParams, const iPlugin )
{
	enum {
		arg_vec_end = 1,
		arg_vec_plane_normal,
		arg_scale,
		arg_color
	};

	new Vector3( vecEnd ); get_array_f( arg_vec_end, vecEnd, 3 );
	new Vector3( vecPlaneNormal ); get_array_f( arg_vec_plane_normal, vecPlaneNormal, 3 );
	new Float: flScale = get_param_f( arg_scale );
	new Float: flColor[ 3 ]; get_array_f( arg_color, flColor, 3 );

	return CSmokeWallPuff__SpawnEntity( vecEnd, vecPlaneNormal, flScale, flColor );
}

/* ~ [ Stocks ] ~ */

/* -> Destroy Entity <- */
stock UTIL_KillEntity( const pEntity ) 
{
	set_entvar( pEntity, var_flags, FL_KILLME );
	set_entvar( pEntity, var_nextthink, get_gametime( ) );
}
