#if defined _api_smokewallpuff_included
	#endinput
#endif
#define _api_smokewallpuff_included

/**
 * @param vecEnd			vecEnd[xyz]
 * @param vecPlaneNormal	vecPlaneNormal[xyz]
 * @param flScale			Scale of sprite
 * @param flColor			Color of sprite[rgb]
 *
 * @return					Returns a index of the smoke wallpuff
 */
native zc_smoke_wallpuff_draw( const Float: vecEnd[ 3 ], const Float: vecPlaneNormal[ 3 ], const Float: flScale = 0.5, const Float: flColor[ 3 ] = { 40.0, 40.0, 40.0 } );