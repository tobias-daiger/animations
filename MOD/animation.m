%Tobias Daiger
function animation_mit_export()
    export_mp4 = true;  
    export_gif = true;  
    
    mp4_filename = 'fadenpendel_animation.mp4';
    gif_filename = 'fadenpendel_animation.gif';

    y_pivot = 5.0;        
    l = 4.0;              
    x_start = 3.5;        
    phi0 = asin(x_start / l); 
    
    g = 9.81;             
    gamma = 0.15;         
    
    omega0 = sqrt(g/l);                   
    omega_ged = sqrt(omega0^2 - gamma^2); 
    
    t_end = 12;
    dt = 0.015;             
    t = 0:dt:t_end;
    
    phi = phi0 * exp(-gamma*t) .* cos(omega_ged*t);
    v_phi = -gamma * phi0 * exp(-gamma*t) .* cos(omega_ged*t) ...
            - phi0 * omega_ged * exp(-gamma*t) .* sin(omega_ged*t);
    
    x = l * sin(phi);
    y = y_pivot - l * cos(phi);
    
    fig = figure('Color', 'w', 'Name', 'Fadenpendel', 'Position', [100, 100, 900, 750]);
    ax = axes('Parent', fig);
    hold(ax, 'on'); grid(ax, 'on'); axis(ax, 'equal');
    
    xlim(ax, [-4.5, 4.5]);
    ylim(ax, [0, 5.5]);
    xlabel(ax, 'x [m]', 'FontSize', 12); 
    ylabel(ax, 'y [m]', 'FontSize', 12);
    title(ax, 'Animation Fadenpendel', 'FontSize', 13);
    
    fill(ax, [-0.4, 0.4, 0.4, -0.4], [y_pivot, y_pivot, y_pivot+0.12, y_pivot+0.12], 'k');
    
    faden = plot(ax, [0, x(1)], [y_pivot, y(1)], 'k-', 'LineWidth', 2);
    kugel = plot(ax, x(1), y(1), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 14);
    
    peak_x = [x(1)];
    peak_y = [y(1)];
    
    plot(ax, x(1), y(1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', [0.75 0.75 0.75], 'MarkerEdgeColor', 'none');
    text(ax, x(1) + 0.2, y(1), 'P_1', 'FontSize', 13, 'FontWeight', 'bold', 'Color', 'k');
    
    if export_mp4
        v_writer = VideoWriter(mp4_filename, 'MPEG-4');
        v_writer.FrameRate = 1/dt; % Entspricht der Zeitauflösung (~66 FPS)
        open(v_writer);
    end

    for k = 2:length(t)
        if ~isvalid(fig) || ~isvalid(faden)
            break;
        end
        
        set(faden, 'XData', [0, x(k)], 'YData', [y_pivot, y(k)]);
        set(kugel, 'XData', x(k), 'YData', y(k));
        
        if v_phi(k-1) * v_phi(k) <= 0
            peak_x(end+1) = x(k); %#ok<AGROW>
            peak_y(end+1) = y(k); %#ok<AGROW>
            idx = length(peak_x);
            
            plot(ax, x(k), y(k), 'o', 'MarkerSize', 10, 'MarkerFaceColor', [0.75 0.75 0.75], 'MarkerEdgeColor', 'none');
            
            if x(k) < 0
                text(ax, x(k) - 0.2, y(k), sprintf('P_{%d}', idx), 'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
            else
                text(ax, x(k) + 0.2, y(k), sprintf('P_{%d}', idx), 'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
            end
            
            p_start = [peak_x(idx-1), peak_y(idx-1)];
            p_end   = [peak_x(idx),   peak_y(idx)];
            
            quiver(ax, p_start(1), p_start(2), p_end(1)-p_start(1), p_end(2)-p_start(2), 0, ...
                   'r:', 'LineWidth', 1.8, 'MaxHeadSize', 0.25);
            
            mid_x = (p_start(1) + p_end(1)) / 2;
            mid_y = (p_start(2) + p_end(2)) / 2 + 0.12;
            
            text(ax, mid_x, mid_y, sprintf('s''_{%d}', idx-1), ...
                 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'r', ...
                 'HorizontalAlignment', 'center', ...
                 'BackgroundColor', [1 1 1 0.8], 'Margin', 1);
             
            if idx == 2
                k_start = 1;
            else
                k_start = find(v_phi(1:k-1).*v_phi(2:k) <= 0, idx-2, 'first');
                k_start = k_start(end);
            end
            plot(ax, x(k_start:k), y(k_start:k), 'b:', 'LineWidth', 1.2);
        end
        
        drawnow;
        
        frame = getframe(fig);
        
        if export_mp4
            writeVideo(v_writer, frame);
        end
        
        if export_gif
            im = frame2im(frame);
            [imind, cm] = rgb2ind(im, 256);
            if k == 2
                imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', dt);
            else
                imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', dt);
            end
        end
    end
    
    if export_mp4
        close(v_writer);
        disp(['MP4 erfoglreich gespeichert unter: ', mp4_filename]);
    end
    if export_gif
        disp(['GIF erfolgreich gespeichert unter: ', gif_filename]);
    end
end