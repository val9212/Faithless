#version 150

#moj_import <dynamictransforms.glsl>
#moj_import <projection.glsl>
#moj_import <config.glsl>
#moj_import <globals.glsl>

in vec3 Position;
in vec4 Color;

out vec4 vertexColor;

const int remap_BR_TR_TL_BL[4] = int[4](3, 1, 0, 2);
const int remap_TL_BL_BR_TR[4] = int[4](0, 2, 3, 1);

void main() {
	vec4 tint = Color;
	vec3 pos = (ProjMat * vec4(Position, 1.0)).xyz;
	
    int vertID = remap_BR_TR_TL_BL[gl_VertexID % 4];
	ivec4 ctrlV = ivec4(Color * 255 + 0.5);
	
	switch (int(Position.z)) {
	case 0:
		if (ctrlV.rgb == vec3(239, 50, 61)) { // --- RELOAD SCREEN --- 
			tint = vec4(Reload_Screen[vertID].rgb, Reload_Screen[vertID].a / 1.0 * Color.a);
		} else if (ctrlV.rgb == vec3(16) && // --- CONTAINER BACKGROUND ---
			(ctrlV.a == 208 || ctrlV.a == 192) &&
			abs(pos.x) > 0.99 && abs(pos.y) > 0.99) {
			bool right = pos.x > 0.0;
			bool top = pos.y > 0.0;
			vertID = right ? (top ? 1 : 3) : (top ? 0 : 2);
			tint = Inventory[vertID];
		} break;
	case 1800: 
		if (ctrlV == vec4(vec3(80), 144)) { // --- DEBUG MENU: F3 ---
			tint = Debug_Menu[vertID];
		} break;
	case 2600: 
		if (ctrlV.rgb == vec3(0) && ctrlV.a < 128) { // --- CHAT BOXES ---
			tint = vec4(Chat_Messages[vertID].rgb, Chat_Messages[vertID].a / 0.49803922 * Color.a);
		} break;
	}
		
	vertexColor = tint;
	gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
}
