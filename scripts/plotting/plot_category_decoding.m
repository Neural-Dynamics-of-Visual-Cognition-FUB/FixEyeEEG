function [] = plot_category_decoding()
    figure
    for idx_sub=1:27
        plot(decodingAcc_standard_all(idx,:))
        hold on
    end 
    
    figure
    for idx_sub=1:27
        plot(decodingAcc_bulls_all(idx,:))
        hold on
    end 
    
    
%     figure
%     stdshade(decodingAcc_bulls_all, 0.2)
%     title(sprintf("decodingAccuracy avg bulls s%", methods(idx)))
%     xlabel('time')
%     ylabel('accuracy')
%     xticks([0 40 80 120 160 200 240])
%     set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
%     yline(50);
%     xline(40);
%     ylim([40, 100])    
%     
%     
%     figure
%     stdshade(decodingAcc_standard_all,0.2, 'blue')
%     title(sprintf("decodingAccuracy avg standard %s", methods(idx)))
%     xlabel('time')
%     ylabel('accuracy')
%     xticks([0 40 80 120 160 200 240])
%     set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
%     yline(50);
%     xline(40);
%     ylim([40, 100])
    
    figure
    stdshade(decodingAcc_standard_all,0.2, 'blue')
    hold on 
    stdshade(decodingAcc_bulls_all, 0.2)
    hold on 
    stdshade(difference_wave, 0.2, 'green')
    title(sprintf("category decoding accuracy %s", methods_flag(idx)))
    xlabel('time')
    ylabel('accuracy')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(50);
    xline(40);
    saveas(gca,sprintf( '%scategory_decoding_%s.png',out_path, methods_flag(idx)));

end
end 


