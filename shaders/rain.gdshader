shader_type canvas_item;

#define iResolution 1.0/SCREEN_PIXEL_SIZE
#define iTime TIME * 0.2
#define fragColor COLOR

uniform sampler2D iChannel0 : hint_screen_texture;
uniform float frequency : hint_range(-10.0, 4.0, 0.1) = 2.0;
uniform float size : hint_range(0.001, 0.05, 0.001) = 0.005;
uniform bool distant = false;
uniform vec4 solidColor : source_color = vec4(0.0, 0.5, 1.0, 1.0); //test color
uniform float blend_factor : hint_range(0.0, 1.0) = 0.4; //was 0.5
uniform float refractionStrength : hint_range(0.0, 0.1) = 0.0; // Strength of the refraction effect was 0.02
uniform float chromaticAberration : hint_range(0.0, 1) = 0.005; // Strength of the rainbow effect
uniform float dropletRadius : hint_range(0.0, 1.0) = 0.028;
//uniform float specularIntensity : hint_range(0.0, 1.0) = 0.5; // Intensity of specular highlights
uniform float speed = 5;
uniform float frequency_uniform = 30.0;
uniform bool is_breath = false;
uniform float breath_speed = 0.368;
uniform float breath_freq = 0.021;

// Author: Élie Michel
// License: CC BY 3.0
// July 2017

vec2 rand1(vec2 c){
    mat2 m = mat2(vec2(12.9898,.16180),vec2(78.233,.31415));
	return fract(sin(m * c) * vec2(43758.5453, 14142.1));
}
float randf (vec2 uv, float seed) {
    return fract(sin(dot(uv.xy + seed,
        vec2(12.9898,78.233))) * 58428.5453123);
}

vec2 noise(vec2 p){
	vec2 co = floor(p);
	vec2 mu = fract(p);
	mu = 3.*mu*mu-2.*mu*mu*mu;
	vec2 a = rand1((co+vec2(0.,0.)));
	vec2 b = rand1((co+vec2(1.,0.)));
	vec2 c = rand1((co+vec2(0.,1.)));
	vec2 d = rand1((co+vec2(1.,1.)));
	return mix(mix(a, b, mu.x), mix(c, d, mu.x), mu.y);
}

vec3 randC(float rand){
	if(rand < 0.2){
			return vec3(0.7, 0.7, 0.7);
		}
		else if(rand < 0.4){
			return vec3(1.0, 1.0, 1.0);
		}
		else if(rand < 0.6){
			return vec3(1.0, 0.0, 0.0);
		}
		else if(rand < 0.8){
			return vec3(0.0, 1.0, 0.0);
		}
		else if(rand < 1.0){
			return vec3(0.0, 0.0, 1.0);
		}
}

vec3 filter(vec3 screen, vec2 uv){
	float approx = 0.01;
	float rand = randf(uv, 0.0);
	float rand2 = randf(uv, 1.0);
	//if(screen.x <= 0.3 && screen.y <= 0.3 && screen.z <= 0.3){
		//return vec3(0.7, 0.7, 0.7); //grey
	//}
	if(screen.x >= 0.5 && screen.y >= 0.5 && screen.z >= 0.5 &&
             abs(screen.x - screen.y) < approx && abs(screen.y - screen.z) < approx) {
		if(rand2 <= 0.7){
			return vec3(1.0, 1.0, 1.0); //white
		}
		else if(rand2 > 0.7){
			return randC(rand);
		}

	}
	else if(abs(screen.x - screen.y) < approx && abs(screen.y - screen.z) > approx) { //yellow
		if(rand2 <= 0.6){
			return vec3(1.0, 1.0, 1.0); //white
		}
		else if(rand2 > 0.6){
			return randC(rand);
		}
	}
	else if(abs(screen.y - screen.z) < approx && abs(screen.x - screen.y) > approx) { //cyan
		if(rand2 <= 0.6){
			return vec3(1.0, 1.0, 1.0); //white
		}
		else if(rand2 > 0.6){
			return randC(rand);
		}
	}
	else if(abs(screen.x - screen.z) < approx && abs(screen.y - screen.z) > approx) {
		if(rand2 <= 0.6){
			return vec3(1.0, 1.0, 1.0); //white
		}
		else if(rand2 > 0.6){
			return randC(rand);
		}
	}
	else if(screen.x > screen.y && screen.x > screen.z){
		if(rand2 <= 0.6){
			return vec3(1.0, 0.0, 0.0); //red
		}
		else if(rand2 > 0.6){
			return randC(rand);
		}
	}
	else if(screen.y > screen.x && screen.y > screen.z){
		if(rand2 <= 0.6){
			return vec3(0.0, 1.0, 0.0); //greenfn
		}
		else if(rand2 > 0.6){
			return randC(rand);
		}
	}
	else if(screen.z > screen.y && screen.z > screen.x){
		if(rand2 <= 0.6){
			return vec3(0.0, 0.0, 1.0); //bluu
		}
		else if(rand2 > 0.6){
			return randC(rand);
		}
	}
	else{
		return randC(rand);
	}
}


void fragment()
{
	vec2 u = SCREEN_UV,
         v = SCREEN_UV * 0.1,
         n = noise(v*200.); // Displacement

    vec4 screenColor = texture(iChannel0, SCREEN_UV);

    fragColor = textureLod(iChannel0, u, 2.5);

	float frequency2 = frequency_uniform;
    if (is_breath) {
        frequency2 = breath_freq * sin(TIME * breath_speed);
    }

	vec4 albedo_tex = texture(iChannel0,u);
    albedo_tex *= COLOR;
	float oh_no = cos(u.x* TIME*speed)+ sin(u.y* TIME*speed);
    float oh_god = sin(u.y* TIME*speed)+ cos(u.x* TIME*speed);
    float oh_feck = sin(u.y* TIME*speed)+ cos(u.x* TIME*speed);

	vec3 waveColor = vec3(
        sin(oh_no * frequency2 * TIME * speed),
        cos(oh_god * frequency2 * TIME * speed),
        tan(oh_feck * frequency2 * TIME * speed)
    );

    // Loop through the different inverse sizes of drops
    for (float r = 4. ; r > frequency ; r--) {
        vec2 x = iResolution.xy * r * size,  // Number of potential drops (in a grid)
             p = 6.28 * u * x + (n - .5) * 2.,
             s = sin(p);

        // Current drop properties. Coordinates are rounded to ensure a
        // consistent value among the fragment of a given drop.
        //vec4 d = texture(iChannel1, round(u * x - 0.25) / x);
        vec2 v = round(u * x - 0.25) / x;
        vec4 d = vec4(noise(v*200.), noise(v));

        // Drop shape and fading
        float t = (s.x+s.y) * max(0., 1. - fract(iTime * (d.b + .1) + d.g) * 2.);;

        // d.r -> only x% of drops are kept on, with x depending on the size of drops
        if (d.r < (5.-r)*.08 && t > .5) {
            // Drop normal
            vec3 v = normalize(-vec3(cos(p), mix(.2, 2., t-.5)));
             //fragColor = vec4(v * 0.5 + 0.5, 1.0);  // show normals

			vec2 refractedUv = UV + v.xy * refractionStrength;

			vec3 color;
			color.r = texture(iChannel0, refractedUv + vec2(chromaticAberration, 0.0)).r;
			color.g = texture(iChannel0, refractedUv).g;
			color.b = texture(iChannel0, refractedUv - vec2(chromaticAberration, 0.0)).b;
			//vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
			//float specular = pow(max(dot(v, lightDir), 0.0), 32.0) * specularIntensity;
			//color += specular * vec3(1.0);

			// Poor man's refraction (no visual need to do more)
			vec4 dropColor = texture(iChannel0, u - v.xy * 0.3);

			if (distant == true){
				vec2 dropletCenter = round(u * x - 0.25) / x;
				float distanceToDropletCenter = length(u - dropletCenter);
				if (distanceToDropletCenter < dropletRadius) {
					vec3 distantColor = filter(screenColor.rgb, u);
					if(t < 0.75){
						fragColor = vec4(waveColor, 1.0);
					}
					else{
						fragColor = vec4(distantColor, 1.0);
					}

				} else {
					fragColor = mix(dropColor, vec4(color, 1.0), blend_factor);//mix(dropColor, solidColor, blend_factor);
				}

			} else{
				fragColor = dropColor;
			}

        }
    }

    // Debug noise function
    //f = vec4(n, 0.0, 1.0);
}