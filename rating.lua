Rating = 0

RatingSubtraction = { current = 0, max = 1*60 }

function AdjustRating(event, anomalyConditionsReached)
    if event == "completed file" then
        Rating = Rating + zutil.clamp(GridGlobalData.width * GridGlobalData.height / 2, 0, 60)
    elseif event == "not an anomaly" then
        Rating = Rating - 30
    elseif event == "anomaly found" then
        Rating = Rating + anomalyConditionsReached * 6
    end
end

function UpdateRatingSubtraction()
    zutil.updatetimer(RatingSubtraction, function ()
        Rating = Rating - 1
    end, 1, GlobalDT)
end

function ReluRating()
    Rating = zutil.relu(Rating)
end