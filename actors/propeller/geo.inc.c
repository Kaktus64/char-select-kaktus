#include "src/game/envfx_snow.h"

const GeoLayout propeller_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_SCALE(LAYER_FORCE, 16384),
		GEO_OPEN_NODE(),
			GEO_DISPLAY_LIST(LAYER_OPAQUE, propeller_Propeller_mesh_layer_1),
			GEO_DISPLAY_LIST(LAYER_ALPHA, propeller_Propeller_mesh_layer_4),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
