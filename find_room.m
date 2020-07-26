function id = find_room(rooms, sign)
   
   min_crowd = 1e7;
   if sign == 0
       for i = 1:length(rooms)
           if length(rooms(i).queue_covid_neg) < min_crowd
               min_crowd = length(rooms(i).queue_covid_neg);
               id = i;
           end
       end
   else
       for i = 1:length(rooms)
           if length(rooms(i).queue_covid_pos) < min_crowd
               min_crowd = length(rooms(i).queue_covid_pos);
               id = i;
           end
       end
   end
end
