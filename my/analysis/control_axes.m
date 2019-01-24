function control_axes(H_axes)
    axes_inds = isprop(H_axes, 'YLim');
    allYLim = get(H_axes(axes_inds), {'YLim'});
    allYLim = cat(2, allYLim{:});
    set(H_axes(axes_inds), 'YLim', [min(allYLim), max(allYLim)]);


end