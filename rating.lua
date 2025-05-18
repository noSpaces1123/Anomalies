Rating = 0

RatingSubtraction = { current = 0, max = 1*60 }

function AdjustRating(event, anomalyConditionsReached)
    if event == "completed file" then
        Rating = Rating + zutil.clamp(GridGlobalData.width * GridGlobalData.height / 6, 0, 60)
    elseif event == "not an anomaly" then
        Rating = Rating - 30
    elseif event == "anomaly found" then
        Rating = Rating + anomalyConditionsReached * 5
    elseif event == "hit arc" then
        Rating = Rating + 3
    elseif event == "did rne queue" then
        Rating = Rating + 15
    end
end

function UpdateRatingSubtraction()
    zutil.updatetimer(RatingSubtraction, function ()
        if Spinner.running or Screen.running then return end
        Rating = Rating - 1
    end, 1, GlobalDT)

    RatingSubtraction.max = zutil.clamp(2 - Rating / 100, .1, math.huge) * 60
end

function ReluRating()
    Rating = zutil.relu(Rating)
end