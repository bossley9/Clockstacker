%% Clockstacker
% Tom W. Davis Presents:
% CLOCKSTACKER

% Developed by:

% Team I (Sauron's Engineers)

% Seat 36 - Henry Xiong
% Seat 35 - Jacob Schweizer
% Seat 34 - Nathaniel DeLong
% Seat 33 - Sam Bossley

% The comments presented within this Matlab file are for your sanity. These
% comments are provided to help understand how Clockstacker works. There
% may be too many comments, but it never hurts to over-explain.

% Hope you enjoy :)



%% A few useful side-notes:
% The entire program is arranged into the following functions as follows:

% * function _Clockstacker_
%   The main executing function containing the game loop
% * function _render()_
%   Redraws the page
% * function _update()_
%   Detects any changes to the game state and applies them
% * function _populate()_
%   Fills the game with entities (blocks)
% * function _newGame()_
%   Starts a new game
% * function _lose()_
%   Executes when the player has lost


% when indices are used in for loops and while loops, certain variables 
% were used to make it easier to understand what exactly was being
% iterated, which proved especially helpful in complex nested for loops.
% The types of indices are listed below as follows:

% _'i'_ indicates that every single block is being called.
% _'n'_ (new layer) indicates only the blocks of the current moving layer.
% _'s'_ (stationed) indicates the last layer to be placed/stationed.
% _'e'_ (extra) indicates all layers above and including the current moving layer.


function Clockstacker
% reset everything
clear, clc, format compact

% declare globals:
global deadBlock f game gameplay j l layerNum reset speed startGame
% * _deadBlock_ is a cell array of booleans declaring whether the given block
%   is 'dead', or has been eliminated (see keypress(varargin) function for 
%   more information).
% * _f_ is the game figure / drawing board.
% * _game_ is a boolean on whether the game is 'running' or not (the game is
%   not running when the user tries to close the window).
% * _gameplay_ is a boolean value that describes whether the user is able to
%   play the game or not (gameplay equals '1' when the user is playing the
%   game, and equals '0' when the player has either lost or won. 
% * _j_ is a boolean determining whether the window is open or not.
% * _l_ is the cell containing all the blocks for each layer.
% * _layerNum_ is the layer currently moving (in this instance, layerNum = 2).
% * _reset_ is a boolean determining whether the game should reset.
% * _speed_ is the rate at which the blocks travel across the screen in.
% * _startGame_ is a boolean that starts the game when it equals '1', or true.

% global colors:
global black brown sky tan white
sky = [0.23 0.55 0.7];
tan = [0.83 0.67 0.47];
brown = [0.51 0.3 0.22];
black = [0.16 0.13 0.08];
white = [1 1 1];

deadBlock = cell(1, 100);
% set all values of _deadBlock_ to '0'
deadBlock(1,:) = {0};
% initialize the game's figure / drawing board
f = figure('ToolBar','none','MenuBar','none','NumberTitle','off','Color',sky,...
    'Resize','off','name','ClockStacker','position',[400,50,800,800],...
    'CloseRequestFcn','global j;j=0;','BackingStore','on','keypressfcn',@keypress);
game = 1;
gameplay = 1;
j = 1;
% declare the array of 20x5 rectangles (blocks)
l = cell(20,5);
layerNum = 2;
reset = 0;
% initial velocity magnitude. Note it is initially positive 
% (the sign determines the direction of the block movement)
speed = 1;
startGame = 0;

%% keypress(varargin)
% The bindings for user input are as follows:
function keypress(varargin)
    % if the user is 'not playing', disable keyboard input
    if gameplay == 0
    else
    
        pause on
        key = get(gcbf,'CurrentKey');
        if strcmp(key,'')
        % if the _'q'_ key is pressed:
        elseif strcmp(key,'q')
            j = 0;
        % if the _'s'_ key is pressed:
        elseif strcmp(key,'s')
            reset = 1;
            startGame = 1;
            newGame();
        % if the _SPACEBAR_ key is pressed:
        elseif strcmp(key,'space')  
            
            % for each block in the layer JUST placed
            for i=5*layerNum-4:5*layerNum
                coord = get(l{i}, 'Position');
                % get the x-position and y-position of each placed block
                xPlaced = coord(1);
                yPlaced = coord(2);
            
                % initialize / reset block-align boolean value
                blockAlignment = 0;
                
                %for each block in the topmost stationed layer
                for s=5*layerNum-9:5*layerNum-5
                    coord = get(l{s}, 'Position');
                    % get the x-position and y-position of each stationed block
                    xStationed = coord(1);
                    yStationed = coord(2);
                
                    % if a given placed block lines up correctly with any
                    % stationed block, blockAlignment is true
                    if xPlaced == xStationed && yPlaced == yStationed + 1 
                        blockAlignment = 1;
                    end
                
                
                end
            
                if blockAlignment == 1
                    % if blocks are aligned, no deleting blocks is necessary
                else
                    % if blocks are not aligned, move this block and other
                    % subsequent blocks off-screen
                    e = i;
                    while e <= 100
                        coord = get(l{e}, 'Position');
            
                        if coord(2) > 0
                           % set the dead blocks' y-positions to be -100 so as
                            % to double-check and make sure the blocks do not
                            % ever appear on-screen
                            coord(2) = -100;
                            l{e}.Position = coord;
                        end
                        % set given block as a dead block
                        deadBlock{e} = 1;
                    
                        % repeat for all following layers
                        e = e + 5;
                    end
                
                end
               
            end
    
            % set the new current layer
            layerNum = layerNum + 1;
        
            %reset speed direction for each layer
            speed = 1;
            
            xPos = 0;
            %for each block in the new layer
            for n=5*layerNum-4:5*layerNum
                coord = get(l{n}, 'Position');
                % only show blocks if they are not dead
                if deadBlock{n} == 0 && coord(2) < 0
                    % make blocks visible in the y-direction 
                    coord(2) = coord(2) * -1;
                    % set new blocks' x-position at 0 
                    coord(1) = xPos;
                    xPos = xPos + 1;
                    l{n}.Position = coord;
                end
            end
        
            %% deadBlock check
            % A double check to make sure the new layer about to appear is not 
            % all comprised of dead blocks.
            deadCheck = 0;
            % only check if the layer has a layer above it
            if layerNum <= 20
                for n=5*layerNum-4:5*layerNum
                    if deadBlock{n} == 1
                        deadCheck = deadCheck + 1;
                    end
                end
                % if all blocks in the new layer appear to be dead
                if deadCheck == 5
                    % the user has just lost,
                    % execute the _lose()_ function.
                    lose()
                end
        
            end
        end
    end
end

%% Introduction
    % This section pertains to the opening text / menu screen of the game.

    % set figure/plot presets (range of x and y axes, disable visibility of
    % the axes, and set background color of the plot)
    axis([0 15 0 20])
    axis off
    set(gca,'Color',sky)
    
    pause(0.5)
    introTitle=text(7.5,18,'Tim W. Duvis presents:','color',white,'FontName','Source Sans Pro','FontSize',16,'HorizontalAlignment','center');
    pause(0.7)
    title=text(7.5,16,'CLOCKSTACKER','color',white,'FontName','SF Distant Galaxy','FontSize',65,'HorizontalAlignment','center');
    pause(0.7)
    subTitle=text(7.5,14.5,'AN OHIO STATE ENGINEERING GAME','color',white,'FontName','Source Sans Pro','FontSize',16,'HorizontalAlignment','center');    
    pause(0.7)
    credits=text(7.5,10,'Created by Henry Xiong, Jacob Schweizer, Nathaniel DeLong and Sam Bossley','color',white,'FontName','Source Sans Pro','FontSize',16,'HorizontalAlignment','center');
    pause(0.7)
    startGameKey=text(7.5,7,'press the s key to play','color',white,'FontName','Source Sans Pro','FontSize',16,'HorizontalAlignment','center');
    pause(0.7)
    while 1 < 2
        pause(0.7)
        if startGame == 1
            delete(introTitle)
            delete(title)
            delete(subTitle)
            delete(credits)
            delete(startGameKey)
            
            cla
%            newGame()
            break
        end
    end



end
%% render()
function render()
    global j
    global black sky
    % double check to make sure the game stops rendering if the 
    % program has already been terminated
    if j == 0
        delete(gcf)
        close(f)
    end
    
    % draws figure boundaries (the square border)
    line([0 15 15 0 0],[0 0 20 20 0],'Color',black)
    
    % draws all rectangles / blocks
    global l
    for i=1:100
        l{i};
    end

    % set figure/plot presets
    axis([0 15 0 20])
    axis off
    set(gca,'Color',sky)
    
end

%% update()
function update()
    
    global deadBlock j l layerNum speed
    if j == 0
        delete(gcf)
        close(f)
        j = 0;
    end
    
    maxX = 1; minX = 14;
    % find the rightmost and leftmost x-positions
    % of the current moving layer
    for n=5*layerNum-4:5*layerNum
        % make sure the x-position values are not coming from dead blocks
        if deadBlock{n} == 0
            coord = get(l{n}, 'Position');
    
            if coord(1) >= maxX
                maxX = coord(1);
            end
            if coord(1) < minX
                minX = coord(1);
            end
        end
    end
    
    % if the moving layer reaches the x boundaries 
    % of the figure/ plot, change direction
    if maxX >= 14 && speed > 0
        speed = speed * -1;
    end
    if minX < 1 && speed < 0
        speed = speed * -1;
    end
    
    % update layer(s) with the new velocity
    for i=1:100
        coord = get(l{i}, 'Position');
        
        % update x-positions
        if i > 5*(layerNum-1) && deadBlock{i} == 0
            coord(1) = coord(1) + speed;
            l{i}.Position = coord;
        end
        
    end
    
end

%% populate()
function populate()
    global l
    global brown black sky tan white
    
    for r=1:20
        for c=1:5
            i = 5*(r-1) + c;
            %% initialize colored blocks
            % black
            if i>=96 || i==17 || i==18 || i==19  || i==22 || i==23 || i==24 || i==27 || i==28 || i==29 || i==32 || i==33 || i==34 || i==37 || i==38 || i==39 || i==42 || i==43 || i==44 || i==47 || i==48 || i==49 || i==52 || i==53 || i==54 || i==57 || i==58 || i==59 || i==62 || i==63 || i==64 || i==67 || i==68 || i==69
                l{i} = rectangle('Position',[ c+4 r-1 1 1],'FaceColor',black,'EdgeColor',sky,'LineWidth',2);
            % brown
            elseif i >= 11 && i <=16 || i==20 || i==21 || i==25 || i==26 || i==30 || i==31 || i==35 || i==36 || i==40 || i==41 || i==45 || i==46 || i==50 || i==51 || i==55 || i==56 || i==60 || i==61 || i==65 || i==66 || i==70
                l{i} = rectangle('Position',[ c+4 r-1 1 1],'FaceColor',brown,'EdgeColor',sky,'LineWidth',2);
            % tan
            elseif i <= 10 || ( i >= 71 && i <= 75 )
                l{i} = rectangle('Position',[ c+4 r-1 1 1],'FaceColor',tan,'EdgeColor',sky,'LineWidth',2);
            % white
            else
                l{i} = rectangle('Position',[ c+4 r-1 1 1],'FaceColor',white,'EdgeColor',sky,'LineWidth',2);
            end
        end
    end
end

%% newGame()
function newGame()
    cla
    global deadBlock gameplay j l layerNum reset
    global black sky
    
    deadBlock = cell(1, 100);
    % set all values of _deadBlock_ to '0'
    deadBlock(1,:) = {0};

    gameplay = 1;

    l = cell(20,5);
    layerNum = 2;
    
    reset = 0;
    
    % set figure/plot presets
    axis([0 15 0 20])
    axis off
    set(gca,'Color',sky)
    
    InstructionQuit=text(7.5,15,'Press q at any time to quit the game, or s to reset the game','color','w','FontSize',14,'HorizontalAlignment','center');
    pause(2);
    delete(InstructionQuit)
    
    Instruction=text(7.5,15,'Press the SPACEBAR key to drop each layer.','color','w','FontSize',14,'HorizontalAlignment','center');
    pause(2);
    delete(Instruction)
    
    % fill cell _l_ with blocks
    populate()

    % load / set y-positions
    for i=1:100
        coord = get(l{i}, 'Position');
    
        if i > 5*(layerNum)
            coord(2) = coord(2) * -1;
            l{i}.Position = coord;
        end
    end
    
    % draw figure boundaries
    line([0 15 15 0 0],[0 0 20 20 0],'Color',black)
    
    % draw all rectangles
    for i=1:100
        l{i};
    end
    
    
    %% Game Loop
    % This is the main executing game loop. This continues to run until _j_ = 0,
    % or the user tries to close the window.
    pause on
    tic
    while 1 < 2
        % if game is not 'running' (user tries to close the game), close the window
        if j == 0
            delete(gcf)
            break
        end
        if reset == 1
            break
        end
    
        % if user makes it to the top layer
        if layerNum == 21
            
            
            %% final deadBlock check
            % A triple check to make sure the final layer was not 
            % comprised of all dead blocks
            deadCheck = 0;
            for n=5*layerNum-9:5*layerNum-5
                if deadBlock{n} == 1
                    deadCheck = deadCheck + 1;
                end
            end
            % if all blocks in the last layer appear to be dead
            if deadCheck == 5
                % the user has just lost,
                % execute the _lose()_ function.
                lose()
            end
        
            
            gameplay = 0;
        
        
            score = 0;
            for i=1:100
                if deadBlock{i} == 0
                    score = score + 1;
                end
            end
    
            text(7.5,21,sprintf('SCORE: %i/100',score),'color','w','FontName','Source Sans Pro','FontSize',30,'HorizontalAlignment','center');
            text(7.5,-1,sprintf('You built the clocktower \n in %0.1f seconds!', elapsedTime),'color','w','FontName','Source Sans Pro','FontSize',20,'HorizontalAlignment','center');
            
            pause(5);
            delete(gcf)
            break
        end

    
   
        % _render()_ constantly redraws the figure
        render()
        % _update()_ constantly detects and makes changes to the game state (i.e. speed)
        update()
        % pauses the loop for 1 millisecond so the user can see changes (if
        % there was no pause, the user would only see a black window because
        % the game would update too fast for the human eye
        pause(1/10)
        % comment the comment above and uncomment the command below to set game
        % difficulty to 'hard' mode.
        % drawnow
    
        % record the elapsed time from the start of the game
        elapsedTime = toc;
    end
    
    
end

%% lose()
function lose()
    global deadBlock f gameplay j
    gameplay = 0;
    
    score = 0;
    for i=1:100
        if deadBlock{i} == 0
            score = score + 1;
        end
    end
    
    text(7.5,-1,'GAME OVER!','color','w','FontName','Source Sans Pro','FontSize',30,'HorizontalAlignment','center');
    text(7.5,21,sprintf('SCORE: %i/100',score),'color','w','FontName','Source Sans Pro','FontSize',30,'HorizontalAlignment','center');
    pause(5);
    close(f)
    delete(gcf)
    j = 0;
    delete(gcf)
end