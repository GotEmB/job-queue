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

class Consumer
	constructor: (@consume, @limit, @period) ->
		@timestamps = []
	getNextTimestamp: =>
		clearTimestamp = new Date
		clearTimestamp.setSeconds clearTimestamp.getSeconds() - @period
		@timestamps.shift() while @timestamps[0] < clearTimestamp
		nowTimestamp = new Date
		if @timestamps.length < @limit
			nowTimestamp
		else
			nextTimestamp = new Date @timestamps[-@limit..][0]
			nextTimestamp.setSeconds nextTimestamp.getSeconds() + @period
			nextTimestamp

module.exports = JobQueue