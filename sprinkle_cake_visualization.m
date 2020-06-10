% Neil Jacklin
% 10/3/15
%
% Sprinkle Cake Visualization
%
% note: runs MUCH faster in R2013b than R2015a
clear;
close all;
%% Parameters
% number of layers in cake
nLayers = 4;
% cake (layer) shape
shape = 'round'; % 'round' or 'square'
% frosting color
frostingBackgroundColor = 'oldlace';
% size (diameter for round cakes, side length for square cakes)
% length should be equal to nLayers, from bottom to top
sizeInch = [16 12 9 6];
% layer height (same for all layers)
layerHeightInch = 4.0; 
% sprinkles
sprinkleDensityPerSqInch = 100;
sprinkleShape = 'dot'; % 'dot' or 'pill'
sprinkleColorList       = {'pink', 'white',  'tan'}; 
sprinkleProbabilityDist = [   1/2,     1/4,    1/4];
sprinkleRadiusInch = 1/24;
sprinkleLengthInch = 1/4; % pill shape only
%% Color choices
% more choices at http://www.rapidtables.com/web/color/RGB_Color.htm
colorMapKeys = { 'white', 'fwhite', 'oldlace', 'tan', 'pink', 'magenta' };
colorMapValues = { [255 255 255]/255;   % white
                   [255 250 240]/255;   % floral white
                   [253 245 230]/255;   % old lace
                   [210 180 140]/255;   % tan
                   [255 192 203]/255;   % pink
                   [255 000 255]/255 }; % magenta
%% Build the cake
% figure init
figure;
hold on;
title('Sprinkle Cake Visualization');
% set up colormap
nColors = numel(colorMapKeys);
colorMapData = zeros(nColors,3);
for iColor = 1:nColors
    colorMapData(iColor,:) = colorMapValues{iColor};
end
colormap(colorMapData);
% build map container
colorMap = containers.Map( colorMapKeys, colorMapValues );
colorMapIndex = containers.Map( colorMapKeys, 0:(nColors-1) );
% build up from the bottom
% every layer has two parts, the "wall" and the "top"
nSprinkleColors = numel(sprinkleColorList);
sprinkleProbabilityDist = sprinkleProbabilityDist ./ sum(sprinkleProbabilityDist);
cumDistSprinkleColors = cumsum(sprinkleProbabilityDist);
nSprinklesTotal = 0;
for iLayer = 1:nLayers
    fprintf('Cake layer %d...\n',iLayer);
    switch (lower(shape))
        case {'round','circle'}
            [Xwall,Ywall,Zwall] = cylinder(sizeInch(iLayer)/2,360);
            Zwall(2,:) = Zwall(2,:)*layerHeightInch;
            Zwall = Zwall + (iLayer-1)*layerHeightInch;
        case 'square'
            error('square cake shape not yet implemented');
        otherwise
            error('Unsupported cake shape "%s"',shape);
    end
    % add top
    Xtop = Xwall(2,:);
    Ytop = Ywall(2,:);
    Ztop = Zwall(2,:);
    % add color
    Cwall = zeros(size(Xwall));
    Cwall(:) = colorMapIndex(frostingBackgroundColor);
    % plot wall and top
    surf(Xwall,Ywall,Zwall,Cwall);
%     fill3(Xtop(:),Ytop(:),Ztop(:),colorMap(frostingBackgroundColor));
    fill3(Xtop(:),Ytop(:),Ztop(:),Cwall(2,:));
    % add sprinkles 
    switch (lower(shape))
        case {'round','circle'}
            % face
            surfaceAreaSqInch = pi * sizeInch(iLayer) * layerHeightInch;
            nSprinkles = round( sprinkleDensityPerSqInch * surfaceAreaSqInch );
            nSprinklesTotal = nSprinklesTotal + nSprinkles;
            fprintf('   adding %d sprinkles to face of layer %d...\n',nSprinkles,iLayer);
            for i = 1:nSprinkles
                % find center coordinate
                angleDeg = 360*rand(1);
                xSprinkleCenterInch = (sizeInch(iLayer)/2+sprinkleRadiusInch/2)*cosd(angleDeg);
                ySprinkleCenterInch = (sizeInch(iLayer)/2+sprinkleRadiusInch/2)*sind(angleDeg);
                zSprinkleCenterInch = (Zwall(2,1)-Zwall(1,1))*rand(1) + Zwall(1,1);
                % determine color according to distribution
                randColor = rand(1);
                for j = 1:nSprinkleColors
                    if ( randColor <= cumDistSprinkleColors(j) )
                        sprinkleColor = sprinkleColorList{j};
                        break;
                    end
                end
                switch (lower(sprinkleShape))
                    case 'dot'
                        [XS,YS,ZS] = sphere(8);
                        XS = XS * sprinkleRadiusInch;
                        XS = XS + xSprinkleCenterInch;
                        YS = YS * sprinkleRadiusInch;
                        YS = YS + ySprinkleCenterInch;
                        ZS = ZS * sprinkleRadiusInch;
                        ZS = ZS + zSprinkleCenterInch;
                        if ( i == 1 )
                            CS = zeros(size(XS));
                        end
                        CS(:) = colorMapIndex(sprinkleColor);
                        surf(XS,YS,ZS,CS);
                    case 'pill'
                        error('pill-shaped sprinkles not yet supported');
                    otherwise
                        error('Unsupported sprinkle shape "%s"',sprinkleShape);
                end
            end
            % top
            if ( iLayer < nLayers )
                surfaceAreaSqInch = pi * ( (sizeInch(iLayer)/2)^2 - (sizeInch(iLayer+1)/2)^2 );
            else
                surfaceAreaSqInch = pi * (sizeInch(iLayer)/2)^2;
            end
            nSprinkles = round( sprinkleDensityPerSqInch * surfaceAreaSqInch );
            nSprinklesTotal = nSprinklesTotal + nSprinkles;
            fprintf('   adding %d sprinkles to top of layer %d...\n',nSprinkles,iLayer);
            for i = 1:nSprinkles
                % find center coordinate
                angleDeg = 360*rand(1);
                if ( iLayer < nLayers )
                    radiusInch = (sizeInch(iLayer)/2-sizeInch(iLayer+1)/2)*sqrt(rand(1))+sizeInch(iLayer+1)/2;
                else
                    radiusInch = (sizeInch(iLayer)/2)*sqrt(rand(1));
                end
                xSprinkleCenterInch = radiusInch*cosd(angleDeg);
                ySprinkleCenterInch = radiusInch*sind(angleDeg);
                zSprinkleCenterInch = Zwall(2,1) + sprinkleRadiusInch/2;
                % determine color according to distribution
                randColor = rand(1);
                for j = 1:nSprinkleColors
                    if ( randColor <= cumDistSprinkleColors(j) )
                        sprinkleColor = sprinkleColorList{j};
                        break;
                    end
                end
                switch (lower(sprinkleShape))
                    case 'dot'
                        [XS,YS,ZS] = sphere(8);
                        XS = XS * sprinkleRadiusInch;
                        XS = XS + xSprinkleCenterInch;
                        YS = YS * sprinkleRadiusInch;
                        YS = YS + ySprinkleCenterInch;
                        ZS = ZS * sprinkleRadiusInch;
                        ZS = ZS + zSprinkleCenterInch;
                        if ( i == 1 )
                            CS = zeros(size(XS));
                        end
                        CS(:) = colorMapIndex(sprinkleColor);
                        surf(XS,YS,ZS,CS);
                    case 'pill'
                        error('pill-shaped sprinkles not yet supported');
                    otherwise
                        error('Unsupported sprinkle shape "%s"',sprinkleShape);
                end
            end
        case 'square'
            error('square cake shape not yet implemented');
        otherwise
            error('Unsupported cake shape "%s"',shape);
    end 
end
% view options
shading flat;
axis equal;
caxis([0 nColors-1]);
set(gca,'Color',[0.5 0.5 0.5]); % gray background
view([45 15]);
% summary stats
fprintf('Total number of sprinkles = %d\n',nSprinklesTotal);
fprintf('Cake complete.\n');
fprintf('\n');
