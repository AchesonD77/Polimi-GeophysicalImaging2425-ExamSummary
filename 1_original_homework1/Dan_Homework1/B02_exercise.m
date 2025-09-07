% -------------------------------------------------------------------------
%       Acoustic wave equation finite diference simulator
% -------------------------------------------------------------------------

% ----------------------------------------
% Design an example showing that Mie scattering produces attenuation
% Suggestion: build an uniform medium, insert a source in the center of 
% the model and 2 receivers, one on the left and one 
% on the right of the source, simmetrically.
% Now, on one of the 2 sides of the source, add to the velocity model
% random variations (zero mean, anomalies below wavelength) and
% verify on the seismic traces that the wavefront crossing the "noisy" zone
% is more attenuated


% -------------------------------------------------------------------------
%       Acoustic wave equation finite diference simulator
% -------------------------------------------------------------------------
%
% This file is a manual and example script using the acoustic simulator
% The user defines the velocity model, the source parameters and 
% the simulation parameters
% The program displays the "evolving" acoustic pressure field amplitude
% in a movie-like figure (snapshots)
% The user can define an optional set of receivers positions: in this case
% the program shows and outputs the pressure recorded at the receivers
% (seismic traces). The receivers that are out of the model are
% automatically rejected, and so the seismic traces can be less than the
% input receivers: the output structure contains the actual position of the
% 'valid' receivers
%
% -------------------------------------------------------------------------
% 1. Model parameters in structure 'model'
%
% Compulsory parameters
% model.x: vector of x grid coordinates [m], Nx elements
% model.z: vector of z grid coordinates [m], Nz elements
% model.vel: matrix of velocity values [m/s], (Nz,Nx) elements
%
% Optional parameters
% model.recx: vector of x coordinates of receivers [m], Nr elements
% model.recz: vector of z coordinates of receivers [m], Nr elements
% model.dtrec: max time sampling interval for seismic traces [s]
%
% -------------------------------------------------------------------------
% 2. Source parameters in structure 'source'
% source coordinates are rounded to nearest grid point
% all of them can be **vectors**, in order to simulate multiple sources
%
% Compulsory parameters
% source.x:  x coordinate of source [m]
% source.z:  z coordinate of source [m]
% source.f0: central frequency of source Ricker wavelet [Hz]
% source.t0: time of source emission (referred to max peak of Ricker)
% source.type: 1 is Ricker, 2 is sinusoid at frequency source.f0
% source.amp: multiplier of source amplitude
%
% -------------------------------------------------------------------------
% 3. Simulation and graphic parameters in structure 'simul'
%
% simul.timeMax:     max simulation time [s]
% simul.borderAlg:   Absorbing boundaries (Yes:1, No:0)
% simul.printRatio:  pressure map shown every printRatio comput. time steps
% simul.higVal:  colormap between -highVal and + highVal (from 0 to 1)
% simul.lowVal:  values between -lowVal and +lowVal zeroed (from 0 to 1)
% simul.bkgVel:  velocity matrix as  a "shadow" in the images (1:yes, 0:no)
%
% Optional parameters
% simul.cmap:    colormap (default 'gray')
%
% -------------------------------------------------------------------------
% 4. Acoustic simulator program call
%
%  recfield=acu2Dpro(model,source,simul);
%
%  recfield.time: time axis of recorded signal [s], Nt elements
%  recfield.data: matrix of pressure at the receivers, (Nt,Nr1)
%  recfield.recx: vector of x grid coordinates of receivers [m], Nr1 elements
%  recfield.recz: vector of z grid coordinates of receivers [m], Nr1 elements
%
% -------------------------------------------------------------------------
% 5. Plotting seismic trace program call
%
%  seisplot2(recfield.data,recfield.time)
% 
%   [fact]=seisplot2(datain,t,tr,scal,pltflg,scfact,colour,clip)
%  
%   function for plotting seismic traces
%  
%   INPUT
%   datain  - input matrix of seismic traces
%   t       - time axis
%   tr      - trace axis
%   scal    - 1 for global max, 0 for global ave, 2 for trace max
%   pltflg  - 1 plot only filled peaks, 0 plot wiggle traces and filled peaks,
%             2 plots wiggle traces only, 3 imagesc gray, 4 pcolor gray
%   scfact  - scaling factor
%   colour  - trace colour, default is black
%   clip    - clipping of amplitudes (if <1); default no clipping
%  
%   OUPTPUT
%   fact    - factor that matrix was scaled by for plotting
%   if you want to plot several matrices using the same scaling factor,
%   capture 'fact' and pass it as input variable 'scal' to future matrices
%   with 'scfact' set to 1
% 
% -------------------------------------------------------------------------
% 6. Essential theory
%
%  Sampling interval for stability (computed automatically)
%  dt=0.95*sqrt(1/2)*min(dx,dz)/vMax
%
%  Courant-Friedrick-Levy (CFL) stability condition (display warning)
%  dx<(vMin/(f0*2*8)))
%  dz<(vMin/(f0*2*8)))
%
%  -----------
%  Ricker wavelet
%
%                  *                        !    ***
%                 * *                       !   * ! *
%    ____________*___*___________ T         !  *  !   *
%    ********   *     *   *******           ! *   !     *
%            ***       ***                  !*    !        * * * *
%             >   TD    <                   ------+---------------- F
%                                                F0
%
%    s(t) = (1-Y2*T*T)*exp(-Y2*T*T/2)   S(f) = 2*F^2/(f0^3*sqrt(pi))*
%    Y2 = 2*pi^2*f0^2                     *exp(-F*F/(f0^2))
%    TD = sqrt(6)/(pi*f0)
%
%  -----------

clear all
% Scattering by sub-wavelength heterogeneities 
% (Mie-like regime for acoustics): energy is redistributed out of the forward direction.
% Lower f, more sub-λ (weaker scattering)

% ----------------------------------------
% 1. Model parameters

model.x   = 0:1:500;    % horizontal x axis sampling
model.z   = 0:1:500;     % vertical   z axis sampling

% temporary variables to compute size of velocity matrix
Nx = numel(model.x);
Nz = numel(model.z);

% example of velocity model assignement
% two layers with an interface at z_interface meters depth
x_interface=250;
model.vel=zeros(Nz,Nx);      % initialize matrix

variation_std = 100; % strength of heterogeneity. Increase to get stronger scattering (more attenuation/coda).

%// Note that the medium is separated in the middle of the X-axis
for kx=1:Nx
  x=model.x(kx);
  for kz=1:Nz
    z=model.z(kz);
    
    % right is has zero-mean random velocity perturbations
    if x>x_interface
      model.vel(kz,kx)=500 + randn*variation_std;
    % left is uniform
    else
      model.vel(kz,kx)=500;
    end
    
  end
end

% optional receivers in (recx, recz)
% the program round their position on the nearest velocity grid
model.recx  = 100:300:400;
model.recz  = model.recx*0+250;  % ... a trick to have same nr elements  of recx
model.dtrec = 0.004;
Nr=numel(model.recx);

% ----------------------------------------
% 2. Source parameters

source.x    = [250];
source.z    = [250 ]; 
source.f0   = [25 ];
source.t0   = [0.04  ];
source.amp  = [1 ];
source.type = [1];    % 1: ricker, 2: sinusoidal  at f0

% ----------------------------------------
% 3. Simulation and graphic parameters in structure simul

simul.borderAlg=1;
simul.timeMax=0.8;

simul.printRatio=10;
simul.higVal=.02;
simul.lowVal=0.001;
simul.bkgVel=1;

simul.cmap='gray';   % gray, cool, hot, parula, hsv

% ----------------------------------------
% 4. Program call

recfield=acu2Dpro(model,source,simul);

% Plot receivers traces

figure
scal   = 1;  % 1 for global max, 0 for global ave, 2 for trace max
pltflg = 0;  % 1 plot only filled peaks, 0 plot wiggle traces and filled peaks,
             % 2 plot wiggle traces only, 3 imagesc gray, 4 pcolor gray
scfact = 1; % scaling factor
colour = ''; % trace colour, default is black
clip   = 0.95; % clipping of amplitudes (if <1); default no clipping

rec_offset = model.recx-source.x;
seisplot2(recfield.data,recfield.time,rec_offset,scal,pltflg,scfact,colour,clip)
xlabel('receiver-source offset (m)')


axis xy

% coherent, speckled and weaker