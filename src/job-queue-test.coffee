JobQueue = require "./job-queue"
vows = require "vows"
assert = require "assert"

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
				jobQueue = new JobQueue [1..5].map (consumerId) -> new JobQueue.MovingWindowRateLimitedConsumer ((job) -> job.process consumerId), 5, 100
				jobQueue.addConsumers [6..10].map (consumerId) -> new JobQueue.MovingWindowRateLimitedConsumer ((job) -> job.process consumerId), 8, 200
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
			"after 10 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 10
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"435 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 435
			"after 110 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 110
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 410
			"after 160 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 160
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 410
			"after 210 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 210
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"345 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 345
			"after 510 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 510
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"230 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 230
			"after 1010 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 1010
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
							d.setUTCMilliseconds d.getUTCMilliseconds() + (counter++) * 1.5
							d
					]...
				jobQueue.addConsumers [6..10].map (consumerId) ->
					counter = 1
					new JobQueue.CustomRateLimitedConsumer [
						(job) ->
							job.process consumerId
						->
							d = new Date
							d.setUTCMilliseconds d.getUTCMilliseconds() + (counter++) * 2.5
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
			"after 10 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 10
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				">= 480 pending jobs": (jobQueue) ->
					assert jobQueue.pendingJobs >= 480
			"after 110 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 110
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				">= 410 pending jobs": (jobQueue) ->
					assert jobQueue.pendingJobs >= 410
			"after 160 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 160
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				">= 380 pending jobs": (jobQueue) ->
					assert jobQueue.pendingJobs >= 380
			"after 210 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 210
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				">= 350 pending jobs": (jobQueue) ->
					assert jobQueue.pendingJobs >= 350
			"after 510 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 510
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				">= 150 pending jobs": (jobQueue) ->
					assert jobQueue.pendingJobs >= 150
			"after 1010 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 1010
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"0 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 0
	.export module

process.on "uncaughtException", (err) ->
	console.error "Caught exception: " + err
	process.removeAllListeners "uncaughtException"