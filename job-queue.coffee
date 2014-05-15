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
				@consumers
					.map (x) -> consumer: x, timestamp: x.getNextTimestamp()
					.sort (x, y) -> x.timestamp - y.timestamp
			sts[0].consumer.timestamps.push sts[0].timestamp
			setTimeout =>
				@pendingJobs--
				sts[0].consumer.consume job
			, sts[0].timestamp - new Date
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
			nextTimestamp = new Date @timestamps[0]
			nextTimestamp.setSeconds nextTimestamp.getSeconds() + @period
			nextTimestamp

module.exports = JobQueue