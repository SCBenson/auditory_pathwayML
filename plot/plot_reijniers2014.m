function [out, cbar] = plot_reijniers2014(dirs, values, varargin) 
%PLOT_REIJNIERS2014 - plot scatter plots out of data from reijniers2014
%
%   Usage:    colorbar = plot_reijniers2014(dirs, values);
%             colorbar = plot_reijniers2014(dirs, values,'bias',bias);
%             plot_reijniers2014(dirs, values);
%             plot_reijniers2014(dirs, values,'bias',bias,'scatter');
%
%   Input parameters:
%     dirs     : Normed source directions in cartesian coordinates
%     values   : Arbitrary values corresponding to direction in dirs (e.g. 
%                error or probability density)
%     bias     : optional, display arrows indicating the size and direction
%                of local population response biases for different source
%                positions
%     target   : optional, display the target given in Cartesian coordinates
%                as a small cross
%
%   Output parameters:
%        c     : Colorbar of the plot to modify outside of this function.
%
%   Further, plot flags can be specified:  
%
%     'interp'         Plot scattered interoplated data (default).
%   
%     'scatter'        Plot only discrete scattered data instead of inter-
%                      polated scattered data.
%
%   See also: exp_reijniers2014 reijniers2014
%
%   References:
%     R. Barumerli, P. Majdak, R. Baumgartner, J. Reijniers, M. Geronazzo,
%     and F. Avanzini. Predicting directional sound-localization of human
%     listeners in both horizontal and vertical dimensions. In Audio
%     Engineering Society Convention 148. Audio Engineering Society, 2020.
%     
%     J. Reijniers, D. Vanderleist, C. Jin, C. S., and H. Peremans. An
%     ideal-observer model of human sound localization. Biological
%     Cybernetics, 108:169--181, 2014.
%     
%
%   Url: http://amtoolbox.sourceforge.net/amt-0.10.0/doc/plot/plot_reijniers2014.php

% Copyright (C) 2009-2020 Piotr Majdak and the AMT team.
% This file is part of Auditory Modeling Toolbox (AMT) version 1.0.0
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%   AUTHOR: Jonas Reijniers
%   Modified and adapted for amtoolbox
%   by Roberto Barumerli and Michael Sattler, 
%   Acoustics Research Institute, Vienna, Austria, 2019



%% ------ Check input options ---------------------------------------------
definput.flags.plot_type = {'interp','scatter'};
definput.flags.type = {'missingflag', 'fig2a','fig2b', ...
                        'fig3','fig4','fig5','fig6', 'fig7', 'fig3_barumerli2020aes'};
definput.keyvals.bias = [];
definput.keyvals.target = [];
[flags,kv]  = ltfatarghelper({'bias','target'},definput,varargin);

% sphere radius [m]
rad = 1;

%% computing lambert projection considering front and back 
[AZ,EL]=cart2sph(dirs(:,1),dirs(:,2),dirs(:,3));
% front
idxf=find(abs(AZ)<=pi/2);
[xf,yf] = polar_to_lambert(AZ(idxf), EL(idxf), rad);

% back indices
idxb=find(abs(AZ)>=pi/2);
AZpar=AZ-pi; % reverse on the frontal plane for plotting
[xb,yb] = polar_to_lambert(AZpar(idxb), EL(idxb), rad);
xb = -xb;

%% make gridlines
daz=30;
AZgrid=repmat((-90:90),length(-90:daz:90),1)'*pi/180; 
ELgrid=repmat((-90:daz:90)',1,length(-90:90))'*pi/180; 
[xgrid1,ygrid1,zgrid1]=sph2cart(AZgrid,ELgrid,1);
[xgrid2,ygrid2,zgrid2]=sph2cart(ELgrid,AZgrid,1);
[AZgrid1, ELgrid1] = cart2sph(xgrid1,zgrid1,ygrid1); 
[AZgrid2, ELgrid2] = cart2sph(xgrid2,zgrid2,ygrid2); 
[xvergrid,yvergrid] = polar_to_lambert(AZgrid1, ELgrid1, rad);
[xhorgrid,yhorgrid] = polar_to_lambert(AZgrid2, ELgrid2, rad);

% plotting
if flags.do_fig2a
    fig = figure('NumberTitle', 'off', 'Name', 'Fig. 2 (a)');
elseif flags.do_fig2b
    fig = figure('NumberTitle', 'off', 'Name', 'Fig. 2 (b)');
elseif flags.do_fig3
    fig = figure('NumberTitle', 'off', 'Name', 'Fig. 3');
elseif flags.do_fig4
    fig = figure('NumberTitle', 'off', 'Name', 'Fig. 4 (a)');
elseif flags.do_fig5
    fig = figure('NumberTitle', 'off', 'Name', 'Fig. 5');
elseif flags.do_fig6
    fig = figure('NumberTitle', 'off', 'Name', 'Fig. 6');
else 
    fig = figure;
end
         
hold on 
% add data valuess
if flags.do_interp    
    [xg,yg] = meshgrid(-1:5e-3:1);
    Vfq = griddata(xf,yf,values(idxf),xg,yg);
    Vbq = griddata(xb,yb,values(idxb),xg,yg);

    contourf(xg,yg,Vfq, 30, 'LineColor','none');
    contourf(xg+2,yg,Vbq, 30, 'LineColor','none');
end

if flags.do_scatter 
    scatter(xf,yf,30,values(idxf),'filled','r');
    scatter(xb+2,yb,30,values(idxb),'filled');
end

% plot grid
grid_color = 100 * [1 1 1] ./ 255;
plot(xvergrid,yvergrid, 'Color', grid_color);
plot(xhorgrid,yhorgrid, 'Color', grid_color); 
plot(xvergrid+2,yvergrid, 'Color', grid_color);
plot(xhorgrid+2,yhorgrid, 'Color', grid_color);
text(-0.3, -1.35, 'FRONT', 'FontSize',13);
text(1.75, -1.35, 'BACK', 'FontSize',13);
set(gca,'XColor', 'none','YColor','none');

%%
if ~isempty(kv.bias)
% front indices
    bias = kv.bias;
    bias = bias + dirs; 
    [AZ,EL]=cart2sph(bias(:,1),bias(:,2),bias(:,3));
    [xfb,yfb] = polar_to_lambert(AZ(idxf), EL(idxf), rad);

% back indices
    AZpar=AZ-pi; % of pi/2)
    [xbb,ybb] = polar_to_lambert(AZpar(idxb), EL(idxb), rad);
    xbb = -xbb;
    
    q1 = quiver(xf,yf,xfb-xf,yfb-yf);
    q1.Color = 'black';
    q1.MaxHeadSize = 0.05;
    q2 = quiver(xb+2,yb,xbb-xb,ybb-yb);
    q2.Color = 'black';
    q2.MaxHeadSize = 0.05;
%     q2.AutoScaleFactor = 1.5;
end

if ~isempty(kv.target)
% front indices
    [AZ,EL]=cart2sph(kv.target(:,1),kv.target(:,2),kv.target(:,3));
    idxf=find(abs(AZ)<=pi/2);
    if ~isempty(idxf)
        [xfb,yfb] = polar_to_lambert(AZ(idxf), EL(idxf), rad);
        q1 = plot(xfb,yfb,'x');
        q1.Color = 'blue';
    end
% back indices
    idxb=find(abs(AZ)>=pi/2);
    if ~isempty(idxb)
        AZpar=AZ-pi; % of pi/2)
        [xbb,ybb] = polar_to_lambert(AZpar(idxb), EL(idxb), rad);
        xbb = -xbb;
        q2 = plot(xbb+2,ybb,'x');
        q2.Color = 'blue';
    end
end

axis([-1 3 -1 1])
pbaspect([2 1 1]);
colormap(flipud(hot)); 
c = colorbar;
box on;  

if nargout == 1
    out = fig;
elseif nargout == 2
    out = fig;
    cbar = c;
end

function [x,y] = polar_to_lambert(az, el, rad)
    % convert polar coordinates to Lambert equal area projection
    % equal area transformation
    % for a reference see 
    % http://mathworld.wolfram.com/StereographicProjection.html
    % and 
    % Formulas 22-4 (p173), 24-13 and 24-14 (p. 185-186) in
    % Snyder, J. P. Map Projections - A Working Manual. 
    % U. S. Geological Survey Professional Paper 1395. 
    % Washington, DC: U. S. Government Printing Office, pp. 154-163, 1987. 
    az_0 = 0;
    k = sqrt(2 ./ (eps + 1  + (cos(el) .* cos(az - az_0))));
    x = k * rad .* cos(el) .* sin(az - az_0) ./ sqrt(2); % ./sqrt(2) normalizing
    y = k * rad .* sin(el) ./ sqrt(2);

