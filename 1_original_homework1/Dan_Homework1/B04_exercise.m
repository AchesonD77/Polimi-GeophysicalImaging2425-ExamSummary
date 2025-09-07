% ----------------------------------------
% Refraction 
% ----------------------------------------
% run the code B04_exercise.p
% pay attention it wil ask in the command window the last 2 digits of 
% your matricola nr
% wait the end of the execution and , on the seismic traces gather,
% obtain the velocity  of the two layers and the depth of the interface
% below the receivers line, using the refraction time intercept method
% 
% -------------------------------------------------------------------------


% my student number is 10949251
% we can see there are 3 lines,
% direct wave, relected wave, and head wave(refraction)

% we got 4 points.
% from direct wave: 40m, 0.109719s; 110m, 0.231194s;
% from head wave: 300m, 0.478063s; 380m, 0.544678s;


% delta x / delta t = velocity =>

% direct wave, 40-110m, I read it from the steep straight line at small offsets.
% v1 = (110-40)/(0.231194-0.109719) = 576 m/s

% head wave, 300-380m, The velocity of the lower (refractor) layer.
% v2 = (380-300)/(0.544678-0.478063) = 1201 m/s

% In refraction we must have v2 > v2

% depth, intercept-time formula
% depth = (t*v1*v2)/(2*sqr(v2^2-v1^2)) = 75.0 m

% cretical angle, The incidence angle in the upper layer that produces the critically refracted wave.
% angle = arcsin(v1/v2) ≈ 28.7°

% crossover distance
% cd = 253 m
