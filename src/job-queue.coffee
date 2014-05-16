class JobQueue
	constructor: ->
		@consumers = []
		@pendingJobs = 0
		@addConsumers arguments...
	addConsumers: (consumes = [], limit, period) =>
		@consumers.push consumes.map((x) -> new Consumer x, limit, period)...
	enqueue: (jobs...) =>
		jobs.forEach (job) =>
			sts =
				(@consumers
					.map (x) -> consumer: x, timestamp: x.getNextTimestamp()
					.sort (x, y) -> x.timestamp - y.timestamp
				)[0]
			sts.consumer.timestamps.push sts.timestamp
			setTimeout =>
				@pendingJobs--
				sts.consumer.consume job
			, sts.timestamp - new Date
			@pendingJobs++
		@pendingJobs

class Consumer
	constructor: (@consume, @limit, @period) ->
		@timestamps = []
	getNextTimestamp: =>
		clearTimestamp = new Date
		clearTimestamp.setUTCMilliseconds clearTimestamp.getUTCMilliseconds() - @period
		@timestamps.shift() while @timestamps[0] < clearTimestamp
		nowTimestamp = new Date
		if @timestamps.length < @limit
			nowTimestamp
		else
			nextTimestamp = new Date @timestamps[@timestamps.length - @limit]
			nextTimestamp.setUTCMilliseconds nextTimestamp.getUTCMilliseconds() + @period
			nextTimestamp

module.exports = JobQueue