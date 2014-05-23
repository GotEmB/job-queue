JobQueue = require "./job-queue"
vows = require "vows"
assert = require "assert"

assert.withinBounds = (value, min, max) ->
	assert min <= value <= max, "expected within [#{min} .. #{max}], got #{value}"

vows.describe "job-queue"
	.addBatch
		"With no consumers or jobs":
			topic: new JobQueue
			"No consumers": (jobQueue) ->
				assert.deepEqual jobQueue.consumers, []
			"No pending jobs": (jobQueue) ->
				assert.equal jobQueue.pendingJobs, 0
		"With MovingWindowRateLimitedConsumer and 500 jobs":
			topic: ->					
				jobQueue = new JobQueue [1..5].map (consumerId) -> new JobQueue.MovingWindowRateLimitedConsumer ((job) -> job.process consumerId), 5, 300
				jobQueue.addConsumers [6..10].map (consumerId) -> new JobQueue.MovingWindowRateLimitedConsumer ((job) -> job.process consumerId), 8, 600
				for jobId in [1..500] then do (jobId) ->
					jobQueue.enqueue
						id: jobId
						process: (consumerId) ->
				jobQueue
			"initially":
				topic: (jobQueue) -> jobQueue
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"500 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 500
			"after 30 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 30
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"435 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 435
			"after 330 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 330
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 410
			"after 480 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 480
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 410
			"after 630 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 630
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"345 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 345
			"after 1530 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 1530
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"230 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 230
			"after 3030 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 3030
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"0 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 0
		"With CustomRateLimitedConsumer and 500 jobs":
			topic: ->					
				jobQueue = new JobQueue [1..5].map (consumerId) ->
					counter = 1
					new JobQueue.CustomRateLimitedConsumer [
						(job) ->
							job.process consumerId
						->
							d = new Date
							d.setUTCMilliseconds d.getUTCMilliseconds() + (counter++) * 4.5
							d
					]...
				jobQueue.addConsumers [6..10].map (consumerId) ->
					counter = 1
					new JobQueue.CustomRateLimitedConsumer [
						(job) ->
							job.process consumerId
						->
							d = new Date
							d.setUTCMilliseconds d.getUTCMilliseconds() + (counter++) * 7.5
							d
					]...
				for jobId in [1..500] then do (jobId) ->
					jobQueue.enqueue
						id: jobId
						process: (consumerId) ->
				jobQueue
			"initially":
				topic: (jobQueue) -> jobQueue
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"500 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 500
			"after 30 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 30
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"480 ± 25 pending jobs": (jobQueue) ->
					assert.withinBounds jobQueue.pendingJobs, 480 - 25, 480 + 25
			"after 330 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 330
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 ± 25 pending jobs": (jobQueue) ->
					assert.withinBounds jobQueue.pendingJobs, 410 - 25, 410 + 25
			"after 480 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 480
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"380 ± 25 pending jobs": (jobQueue) ->
					assert.withinBounds jobQueue.pendingJobs, 380 - 25, 380 + 25
			"after 630 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 630
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"350 ± 25 pending jobs": (jobQueue) ->
					assert.withinBounds jobQueue.pendingJobs, 350 - 25, 350 + 25
			"after 1530 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 1530
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"150 ± 25 pending jobs": (jobQueue) ->
					assert.withinBounds jobQueue.pendingJobs, 150 - 25, 150 + 25
			"after 3030 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 3030
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"0 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 0
	.export module

process.on "uncaughtException", (err) ->
	console.error "Caught exception: " + err
	process.removeAllListeners "uncaughtException"