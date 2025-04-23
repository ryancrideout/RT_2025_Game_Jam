shader_type canvas_item;

uniform float base_alpha : hint_range(0.0, 1.0) = 0.6;
uniform float max_alpha : hint_range(0.0, 1.0) = 0.7;

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    float circle = smoothstep(0.5, 0.35, dist); // soft circular mask
    vec4 tex = texture(TEXTURE, UV);

    // Multiply the texture's alpha by the circle mask and base_alpha, then clamp to max_alpha.
    tex.a = min(tex.a * circle * base_alpha, max_alpha);

    COLOR = tex;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
