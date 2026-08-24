#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:chunksection.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:vertex_utils.glsl>
#moj_import <config.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexLight;
out vec4 vertexColor;
out vec2 texCoord0;

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
	return texture(lightMap, clamp((uv / 256.0) + 0.5 / 16.0, vec2(0.5 / 16.0), vec2(15.5 / 16.0)));
}

vec3 rendSwing(vec3 blockPos, float value) {
	vec3 rand = floor(Position);
	float theta = GameTime * 1600.0 + dot(rand, vec3(1.0));
	float sinX = sin(theta) * 0.1;
	float sinZ = sin(theta * 1.618) * 0.1;
	float cosX = 1.0 - 0.5 * sinX * sinX;
	float cosZ = 1.0 - 0.5 * sinZ * sinZ;
	blockPos.yz = vec2(cosX * blockPos.y - sinX * blockPos.z, sinX * blockPos.y + cosX * blockPos.z);
	blockPos.xy = vec2(cosZ * blockPos.x - sinZ * blockPos.y, sinZ * blockPos.x + cosZ * blockPos.y);
	return (-Position + blockPos + rand + 0.5) * value;
}

void main() {
	texCoord0 = UV0;
	vec4 tint = Color * minecraft_sample_lightmap(Sampler2, UV2);
	vec4 shade = minecraft_sample_lightmap(Sampler2, UV2);

	mat4 ViewMat = Orthographic ? getOrthoMat(ProjMat, 0.007) : ProjMat;
	mat4 Camera = Orthographic ? getIsometricViewMat(ModelViewMat) : ModelViewMat;

	vec3 ModelOffset = (ChunkPosition - CameraBlockPos) + CameraOffset;
	vec3 pos = Position + ModelOffset;
	vec3 blockPos = fract(Position) - 0.5;
	vec3 absPos = vec3(abs(blockPos.x), (blockPos.y + 0.5), abs(blockPos.z)) * 16;
	vec3 chunkPos = mod(round(Position), 16) + 1;
	int vertID = gl_VertexID % 4;

	switch (Chunk_Loading) {
		case 1:
		pos.y += chunk_translate(ModelOffset, FogRenderDistanceEnd);
		break;
		case 2:
		pos += chunk_quad_fade(ModelOffset, Normal, Position, FogRenderDistanceEnd, vertID);
		break;
	}

	ivec4 ctrlV = ivec4(textureLod(Sampler0, UV0, 0) * 255.0 + 0.5);
	if (ctrlV.a == 181 && Waving_Features && (absPos.xz == vec2(2) || absPos.xz == vec2(3))) {
		if (absPos.y == 1 || absPos.y == 8 || absPos.y == 10) {
			pos += rendSwing(blockPos, Waving_Objects);
		}
	}

	vertexLight = shade;
	vertexColor = tint;

	sphericalVertexDistance = fog_spherical_distance(pos);
	cylindricalVertexDistance = fog_cylindrical_distance(pos);

	gl_Position = ViewMat * Camera * vec4(pos, 1.0);
}
