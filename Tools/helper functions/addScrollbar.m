function h=addScrollbar( ax, varargin )
% Add a scrollbar to one or more axes.
%
% Ex: 
% plot(1:1:10000,sin(1:1:10000))
% addScrollbar( gca, 1, 'y' )
% addScrollbar( gca, 100 )
% Ex2:
% %Control multiple axes with one scrollbar:
% figure;ax(1)=subplot(2,1,1);plot(1:1:10000,sin(1:1:10000));grid on;
% ax(2)=subplot(2,1,2);plot(1:1:10000,sin([1:1:10000]+pi/2));grid on;
% addScrollbar( ax, 10 )
%

t='x';
dx=[];
if ~isempty(varargin)
    dx=varargin{1};
    if numel(varargin)>1
        t=varargin{2};
        if ~any(strcmpi(t,{'x','y'}))
            error('Optional argument must be ''x'' or ''y''');
        end
    end
end

set(gcf,'doublebuffer','on');

%Find data-limits
Max=nan;Min=nan;
for i=1:numel(ax)
    ch=get(ax(i),'children');
    types=get(ch,'type');
    %inds=false(size(ch));
    %for id={'line','image'}
    %    inds=inds|any(strcmpi(types,id{:}));
    %end
    try
        data=get(ch,sprintf('%sdata',t));
    catch
    end
    maxarr=data;
    if iscell(data)
        maxarr=cellfun(@max,data);
    end
    Max=max(Max,max(maxarr));
    minarr=data;
    if iscell(data)
        minarr=cellfun(@min,data);
    end
    Min=min(Min,min(minarr));
end

if numel(ax)>1
    pos=cell2mat(get(ax,'position'));
else
    pos=get(ax,'position');
end
other='x';
if strcmpi(t,'x')
    other='y';
end
lims = get(ax,sprintf('%slim',other));
if ~iscell(lims),lims={lims}; end
[tmp,ind]=min(pos(:,2));
pos=pos(ind,:);
if strcmpi(t,'x')
    %set(get(ax,'xlabel'),'units','normalized');
    %extent=get(get(ax,'xlabel'),'Extent');
    %Newpos=[pos(1) pos(2)-0.1-extent(4) pos(3) 0.05];
    Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];    
else
    Newpos=[pos(1)-0.1 pos(2) 0.05 pos(4)];
end
if isempty(dx)
    dx=(Max-Min)/10;
end
if dx>(Max-Min)
    error('Slider step cannot be larger than the axis limits');
end

c = @(obj,handles)callback(obj,handles,ax,t,dx,lims);
% Creating Uicontrol
h=uicontrol('style','slider',...
    'units','normalized','position',Newpos,...
    'callback',c,'min',Min,'max',Max-dx(1),'value',Min,'SliderStep',[dx,dx]./(Max-Min),...
    'tooltip',get(get(ax(ind),'xlabel'),'string'));
c(h,[]); %run callback to update current/initial value

function callback(obj,handles,ax,t,dx,lims)

set(ax,sprintf('%slim',t),get(obj,'value')+[0 dx]);
other='x';
if strcmpi(t,'x')
    other='y';
end
for i=1:numel(ax)   
    set(ax(i),sprintf('%slim',other),lims{i});
end


