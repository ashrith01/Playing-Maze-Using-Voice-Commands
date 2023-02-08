function [ending,time_to_end] = maze(row,col)

clc;
rand('state',sum(100*clock))

[cc,rr]=meshgrid(1:col,1:row);
state = reshape([1:row*col],row,col); % state identifies connected regions
id = reshape([1:row*col],row,col); % id identifies intersections of maze

% create pointers to adjacent intersections
ptr_left = zeros(size(id));
ptr_up = zeros(size(id));
ptr_right = zeros(size(id));
ptr_down = zeros(size(id));

ptr_left(:,2:size(id,2)) = id(:,1:size(id,2)-1);
ptr_up(2:size(id,1),:) = id(1:size(id,1)-1,:);
ptr_right(:,1:size(id,2)-1) = id(:,2:size(id,2));
ptr_down(1:size(id,1)-1,:) = id(2:size(id,1),:);

% sort graph entities by id
the_maze = cat(2,reshape(id,row*col,1),reshape(rr,row*col,1),reshape(cc,row*col,1),reshape(state,row*col,1),...
    reshape(ptr_left,row*col,1),reshape(ptr_up,row*col,1),reshape(ptr_right,row*col,1),reshape(ptr_down,row*col,1)  );

the_maze = sortrows(the_maze);

id=the_maze(:,1);
rr=the_maze(:,2);
cc=the_maze(:,3);   
state=the_maze(:,4);
ptr_left=the_maze(:,5);
ptr_up=the_maze(:,6);
ptr_right=the_maze(:,7);
ptr_down=the_maze(:,8);
clear the_maze;

% create a random maze
[state, ptr_left, ptr_up, ptr_right, ptr_down]=...
    make_pattern(row,col,id, rr, cc, state, ptr_left, ptr_up, ptr_right, ptr_down);

% show maze
h=figure('KeyPressFcn',@move_spot,'color','#FFFF00');
title(' MAZE (Press Any Key to Give Command) ','FontSize',20)
show_maze(row, col, rr, cc, ptr_left, ptr_up, ptr_right, ptr_down,h);

% start play
cursor_pos=[1,1];
current_id=1;
figure(h)
text(cursor_pos(1),cursor_pos(2), '\diamondsuit', 'HorizontalAlignment', 'Center','color', 'k', 'FontSize', 20);
set(gcf,'Units','normalized');
set(gcf,'position',[0 0 1 .91]);
tic

% keep processing keystrokes until the maze is solved
while ~all(cursor_pos == [col,row])
    waitfor(gcf,'CurrentCharacter')
    set(gcf,'CurrentCharacter','~') % update to another character so repeats are recognized
    % key is updated by move_spot
    play=1;
    ending='Won';
    switch double(key(1))
        case 108 % left
            if ptr_left(current_id)<0 % check for legal move
                current_id=-ptr_left(current_id);
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit','HorizontalAlignment','Center','color','c', 'FontSize', 20);
                cursor_pos(1)=cursor_pos(1)-1;
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit','HorizontalAlignment','Center','color','k', 'FontSize', 20);
            end
        case 114 % right
            if ptr_right(current_id)<0 % check for legal move
                current_id=-ptr_right(current_id);
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit','HorizontalAlignment','Center','color','c', 'FontSize', 20);
                cursor_pos(1)=cursor_pos(1)+1;
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit','HorizontalAlignment','Center','color','k', 'FontSize', 20);
            end
        case 117 % up
            if ptr_up(current_id)<0 % check for legal move
                current_id=-ptr_up(current_id);
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit','HorizontalAlignment','Center','color','c', 'FontSize', 20);
                cursor_pos(2)=cursor_pos(2)-1;
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit','HorizontalAlignment','Center','color','k', 'FontSize', 20);
            end
        case 100 % down
            if ptr_down(current_id)<0 % check for legal move
                current_id=-ptr_down(current_id);
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit','HorizontalAlignment','Center','color','c', 'FontSize', 20);
                cursor_pos(2)=cursor_pos(2)+1;
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit','HorizontalAlignment','Center','color','k', 'FontSize', 20);
            end
        case 500 % stop
            play=0;
            ending='Aborted';
            break;
        otherwise
    end

end

time_to_end=toc;
if(play==1)
    title(cat(2,' Winning Time ',num2str(round(time_to_end*100)/100),'(sec)'),'FontSize',20)
    pause(3);
    close all;
else
    title(cat(2,' Game Aborted Time Elapsed ',num2str(round(time_to_end*100)/100),'(sec)'),'FontSize',20)
    pause(3);
    close all;
end

print_statement = [ending,' Time Elapsed : ',num2str(round(time_to_end*100)/100),'(sec)'];
disp(print_statement)
return


function move_spot(src,evnt)
load('model1net.mat')
recorder1 = audiorecorder(16000,16,1,-1); 
title('Start Speaking.','FontSize',20)
recordblocking(recorder1, 1);
title('End of Recording.','FontSize',20)
pause(0.1)
x = getaudiodata(recorder1);
auditorySpect = helperExtractAuditoryFeatures(x,16000);
command = classify(trainedNet,auditorySpect);
title(upper(command),'FontSize',20)
val=90;
if(command == 'left')
    val = 108;
elseif(command =='right')
        val = 114;
elseif(command =='up')
        val = 117;
elseif(command=='down')
    val = 100;
elseif(command=='stop')
    val = 500;
end
assignin('caller','key',val)
return


function show_maze(row, col, rr, cc, ptr_left, ptr_up, ptr_right, ptr_down,h)
figure(h)
line([.5,col+.5],[.5,.5],'LineWidth',5,'color','r') % draw top border
line([.5,col+.5],[row+.5,row+.5],'LineWidth',5,'color','r') % draw bottom border
line([.5,.5],[1.5,row+.5],'LineWidth',5,'color','r') % draw left border
line([col+.5,col+.5],[.5,row-.5],'LineWidth',5,'color','r')  % draw right border
for ii=1:length(ptr_right)
    if ptr_right(ii)>0 % right passage blocked
        line([cc(ii)+.5,cc(ii)+.5],[rr(ii)-.5,rr(ii)+.5],'LineWidth',5,'color','r');
        hold on
    end
    if ptr_down(ii)>0 % down passage blocked
        line([cc(ii)-.5,cc(ii)+.5],[rr(ii)+.5,rr(ii)+.5],'LineWidth',5,'color','r');
        hold on
    end  
end
axis equal
axis([.5,col+.5,.5,row+.5])

axis off
set(gca,'YDir','reverse')
return


function [state, ptr_left, ptr_up, ptr_right, ptr_down]=make_pattern(row,col,id, rr, cc, state, ptr_left, ptr_up, ptr_right, ptr_down)

while max(state)>1 % remove walls until there is one simply connected region
    tid=ceil(col*row*rand(15,1)); % get a set of temporary ID's
    cityblock=cc(tid)+rr(tid); % get distance from the start
    is_linked=(state(tid)==1); % The start state is in region 1 - see if they are linked to the start
    temp = sortrows(cat(2,tid,cityblock,is_linked),[3,2]); % sort id's by start-link and distance
    tid = temp(1,1); % get the id of the closest unlinked intersection
    
    dir = ceil(8*rand);
    if abs((rr(tid)-row/2))>abs((cc(tid)-col/2))
        if dir>6
            dir=4;
        end
        if dir>4
            dir=3;
        end
    else
        if dir>6
            dir=2;
        end
        if dir>4
            dir=1;
        end
    end
    
    switch dir
    case -1
        
    case 1
        if ptr_left(tid)>0 & state(tid)~=state(ptr_left(tid))
            state( state==state(tid) | state==state(ptr_left(tid)) )=min([state(tid),state(ptr_left(tid))]);
            ptr_right(ptr_left(tid))=-ptr_right(ptr_left(tid));
            ptr_left(tid)=-ptr_left(tid);
        end
    case 2
        if ptr_right(tid)>0 & state(tid)~=state(ptr_right(tid))
            state( state==state(tid) | state==state(ptr_right(tid)) )=min([state(tid),state(ptr_right(tid))]);
            ptr_left(ptr_right(tid))=-ptr_left(ptr_right(tid));
            ptr_right(tid)=-ptr_right(tid);
        end
    case 3
        if ptr_up(tid)>0 & state(tid)~=state(ptr_up(tid))
            state( state==state(tid) | state==state(ptr_up(tid)) )=min([state(tid),state(ptr_up(tid))]);
            ptr_down(ptr_up(tid))=-ptr_down(ptr_up(tid));
            ptr_up(tid)=-ptr_up(tid);
        end
    case 4
        if ptr_down(tid)>0 & state(tid)~=state(ptr_down(tid))
            state( state==state(tid) | state==state(ptr_down(tid)) )=min([state(tid),state(ptr_down(tid))]);
            ptr_up(ptr_down(tid))=-ptr_up(ptr_down(tid));
            ptr_down(tid)=-ptr_down(tid);
        end
    otherwise
        dir
        error('quit')
    end
    
end
return