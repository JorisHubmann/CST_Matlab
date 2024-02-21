%Generates a Figure with the given Name and the given axis 

function [] = plotC(Name, xname, yname, x,y,Field,Contour,Fieldscale, Label)

get(0,'Factory');
set(0,'defaultfigurecolor',[1 1 1]);
linewidth=2;
fontsize=14;

figure('name',Name)
    ax1=axes('Position',[0.1 0.1 .8 .8]);
    plot3=imagesc(x,y,Field,Fieldscale);
    [Lx, Ly]=size(Field);
    pbaspect([Ly,Lx,1])
    %set(gca,'DataAspectRatio',[Ly Lx 1])
    plot3.AlphaData=1;
    set(gca,'FontSize',fontsize)
    d=colorbar;
    xlabel(append(xname,' /mm'))
    ylabel(append(yname,' /mm'))
    hold on
    ax2=axes('Position',[0.1 0.1 .8 .8]);  
    plot2=imagesc(x,y,Contour,[0 1]);
    plot2.AlphaData=.1;
    linkaxes([ax1 ax2]);
    ax2.Visible = 'off'; 
    ax2.XTick = []; 
    ax2.YTick = [];
    colormap (ax1,'jet')
    colormap (ax2,'gray')
    c=colorbar;
    %axis equal;
    %set(gca,'DataAspectRatio',[Ly Lx 1])
    c.Visible='off';
    d.Label.String = Label;
    pbaspect([Ly,Lx,1])
end

