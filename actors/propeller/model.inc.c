Lights1 propeller_Handle_lights = gdSPDefLights1(
	0x13, 0x13, 0x13,
	0x31, 0x31, 0x31, 0x28, 0x28, 0x28);

Gfx propeller_propeller1_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 propeller_propeller1_rgba16[] = {
	#include "actors/propeller/propeller1.rgba16.inc.c"
};

Vtx propeller_Propeller_mesh_layer_1_vtx_0[9] = {
	{{ {9, 186, 5}, 0, {498, 371}, {0, 127, 0, 255} }},
	{{ {0, 186, -10}, 0, {498, 371}, {0, 127, 0, 255} }},
	{{ {-9, 186, 5}, 0, {498, 371}, {0, 127, 0, 255} }},
	{{ {-9, 2, 5}, 0, {498, 371}, {146, 0, 64, 255} }},
	{{ {-9, 186, 5}, 0, {498, 371}, {146, 0, 64, 255} }},
	{{ {0, 186, -10}, 0, {498, 371}, {0, 0, 129, 255} }},
	{{ {9, 186, 5}, 0, {498, 371}, {110, 0, 64, 255} }},
	{{ {9, 2, 5}, 0, {498, 371}, {110, 0, 64, 255} }},
	{{ {0, 2, -10}, 0, {498, 371}, {0, 0, 129, 255} }},
};

Gfx propeller_Propeller_mesh_layer_1_tri_0[] = {
	gsSPVertex(propeller_Propeller_mesh_layer_1_vtx_0 + 0, 9, 0),
	gsSP2Triangles(0, 1, 2, 0, 3, 4, 5, 0),
	gsSP2Triangles(6, 4, 3, 0, 6, 3, 7, 0),
	gsSP2Triangles(6, 7, 8, 0, 6, 8, 5, 0),
	gsSP1Triangle(3, 5, 8, 0),
	gsSPEndDisplayList(),
};

Vtx propeller_Propeller_mesh_layer_4_vtx_0[4] = {
	{{ {-234, 180, 234}, 0, {-16, 1008}, {0, 129, 0, 255} }},
	{{ {-234, 180, -234}, 0, {1008, 1008}, {0, 129, 0, 255} }},
	{{ {234, 180, -234}, 0, {1008, -16}, {0, 129, 0, 255} }},
	{{ {234, 180, 234}, 0, {-16, -16}, {0, 129, 0, 255} }},
};

Gfx propeller_Propeller_mesh_layer_4_tri_0[] = {
	gsSPVertex(propeller_Propeller_mesh_layer_4_vtx_0 + 0, 4, 0),
	gsSP2Triangles(0, 1, 2, 0, 0, 2, 3, 0),
	gsSPEndDisplayList(),
};


Gfx mat_propeller_Handle[] = {
	gsSPSetLights1(propeller_Handle_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPEndDisplayList(),
};

Gfx mat_propeller_Propeller1[] = {
	gsSPGeometryMode(G_CULL_BACK, 0),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, TEXEL0, 0, 0, 0, TEXEL0, 0, 0, 0, TEXEL0, 0, 0, 0, TEXEL0),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, propeller_propeller1_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_propeller_Propeller1[] = {
	gsSPGeometryMode(0, G_CULL_BACK),
	gsDPPipeSync(),
	gsSPEndDisplayList(),
};

Gfx propeller_Propeller_mesh_layer_1[] = {
	gsSPDisplayList(mat_propeller_Handle),
	gsSPDisplayList(propeller_Propeller_mesh_layer_1_tri_0),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx propeller_Propeller_mesh_layer_4[] = {
	gsSPDisplayList(mat_propeller_Propeller1),
	gsSPDisplayList(propeller_Propeller_mesh_layer_4_tri_0),
	gsSPDisplayList(mat_revert_propeller_Propeller1),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

