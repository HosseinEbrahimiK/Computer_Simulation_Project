function id = find_room(rooms, sign)
   
   idx = [];
   min_crowd = 1e7;
   if sign == 0
       for i = 1:length(rooms)
           if length(rooms(i).queue_covid_neg) < min_crowd
               min_crowd = length(rooms(i).queue_covid_neg);
           end
       end
       for j = 1:length(rooms)
           if length(rooms(j).queue_covid_neg) == min_crowd
               idx = [idx, j];
           end
       end
       id = idx(unidrnd(length(idx)));
   else
       for i = 1:length(rooms)
           if length(rooms(i).queue_covid_pos) < min_crowd
               min_crowd = length(rooms(i).queue_covid_pos);
           end
       end
       for j = 1:length(rooms)
           if length(rooms(j).queue_covid_pos) == min_crowd
               idx = [idx, j];
           end
       end
       id = idx(unidrnd(length(idx)));
   end
end
