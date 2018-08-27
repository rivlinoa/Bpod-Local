function control_axes(H_axes)

    allYLim = get(H_axes, {'YLim'});
    allYLim = cat(2, allYLim{:});
    set(H_axes, 'YLim', [min(allYLim), max(allYLim)]);


end