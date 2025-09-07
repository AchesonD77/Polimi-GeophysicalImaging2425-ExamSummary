
% -------------------------------------------------------------------------
%       Acoustic wave equation finite difference simulator
% -------------------------------------------------------------------------

% --------------------------------------------------
% Create your own model and example....DaB05
% My goal is to simulate VSP data (Vertical Seismic Profiling,It is a zero-offset VSP
% and show the effect of a lateral fast body.
% It helps me separate downgoing
% and upgoing waves and understand lateral contrasts
% It mimics a zero-offset VSP near a fast side body. 
% The source is at the surface next to a borehole. Receivers are down the well.

% It helps with check-shot velocity, with detecting hard bodies near the well, and with survey design and risk reduction.
% --------------------------------------------------

clc; clear all;

% 1. Model parameters

model.x   = 0:1:1000;    % horizontal x axis sampling
model.z   = 0:1:400;     % vertical   z axis sampling

% temporary variables to compute size of velocity matrix
Nx = numel(model.x);
Nz = numel(model.z);

% example of veocity model assignement
% two layers with an interface at z_interface meters depth
model.vel = zeros(Nz, Nx);      % initialize matrix

%filling the velocity`in different blocks
for kx = 1: Nx
  x = model.x(kx);
  for kz = 1: Nz
    z = model.z(kz);
    
    % A vertical "fast" block between x = 400–600 m is set to 2000 m/s
    if x < 600 && x > 400
      model.vel(kz, kx) = 2000;

    % Everywhere else the velocity is 1000 m/s
    else
      model.vel(kz, kx) = 1000;
    end
    
  end
end

% optional receivers in (recx, recz)
% the program round their position on the nearest velocity grid
% places receivers (a vertical array)
model.recz  = 100: 20: 400;
model.recx  = model.recz * 0 + 20;  
model.dtrec = 0.004; % Recording sample interval

% ----------------------------------------
% 2. Source parameters, acoustic source
source.x    = 20;
source.z    = 20; 
source.f0   = 25;
source.t0   = 0.04; % starting time
source.amp  = 5;
source.type = 1;    % 1: ricker, 2: sinusoidal  at f0

% ----------------------------------------
% 3. Simulation and graphic parameters in structure simul
simul.borderAlg=1;
simul.timeMax=1; % time sets 1 second

simul.printRatio=10;
simul.higVal=0.30;
simul.lowVal=0.03;
simul.bkgVel=1;

simul.cmap='gray';   % gray, cool, hot, parula, hsv

% ----------------------------------------
% 4. Program call
% runs the finite-difference propagation
recfield=acu2Dpro(model,source,simul);

% Plot receivers traces

figure
scal   = 1;  % 1 for global max, 0 for global ave, 2 for trace max
pltflg = 0;  % 1 plot only filled peaks, 0 plot wiggle traces and filled peaks,
             % 2 plot wiggle traces only, 3 imagesc gray, 4 pcolor gray
scfact = 10; % scaling factor
colour = ''; % trace colour, default is black
clip   = []; % clipping of amplitudes (if <1); default no clipping

seisplot2(recfield.data,recfield.time,[],scal,pltflg,scfact,colour,clip)
xlabel('receiver nr')

