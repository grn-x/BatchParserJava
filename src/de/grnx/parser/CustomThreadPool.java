package de.grnx.parser;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class CustomThreadPool {
	private final Thread[] threads;
	private final BlockingQueue<Runnable> taskQueue;
	private final List<Runnable> pausedTasks;

	private volatile int executedTasks;

	private volatile boolean isPaused;
	private volatile boolean isShutdown;

	public CustomThreadPool(int threadCount) {
		this.taskQueue = new LinkedBlockingQueue<>();
		this.pausedTasks = new ArrayList<>();
		this.threads = new Thread[threadCount];
		this.isPaused = false;
		this.isShutdown = false;

		for (int i = 0; i < threadCount; i++) {
			threads[i] = new Worker("Thread-" + i);
			threads[i].start();
		}
	}

	public int getQueuedTasks() {
		return taskQueue.size();
	}

	public int getPausedTasks() {
		return pausedTasks.size();
	}

	public int getExecutedTasks() {
		return executedTasks;
	}

	public void setExecutedTasks(int value) {
		this.executedTasks = value;
	}

	public void submit(Runnable task) {
		if (!isPaused) {
			taskQueue.add(task);
		} else {
			pausedTasks.add(task);
		}
	}

	public void pause() {// TODO
		isPaused = true;
		while (!taskQueue.isEmpty()) {
			try {
				Thread.sleep(100); // Wait for current tasks to finish
			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
			}
		}
	}

	public void resume() {// TODO
		isPaused = false;
		for (Runnable task : pausedTasks) {
			submit(task);
		}
		pausedTasks.clear();
	}

	public void executeUntil(int numTasks) {// TODO
		for (int i = 0; i < numTasks; i++) {
			int taskId = i;
			submit(() -> {
				System.out.println("Executing task " + taskId + " in " + Thread.currentThread().getName());
				try {
					Thread.sleep(1000); // Simulating task execution
				} catch (InterruptedException e) {
					Thread.currentThread().interrupt();
				}
				System.out.println("Task " + taskId + " completed");
			});
		}
	}

	public void completeAllTasks() {// TODO
		while (!taskQueue.isEmpty() || !pausedTasks.isEmpty()) {
			try {
				Thread.sleep(100); // Wait for all tasks to finish
			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
			}
		}
		shutdown();
	}

	public void shutdown() {
		isShutdown = true;
		for (Thread thread : threads) {
			thread.interrupt();
		}
	}

	public void shutdownNow() {
		isShutdown = true;
		for (Thread thread : threads) {
			thread.interrupt();
		}
		taskQueue.clear();
		pausedTasks.clear();
	}

	private class Worker extends Thread {
		public Worker(String name) {
			super(name);
		}

		public void run() {
			while (!Thread.currentThread().isInterrupted() && !isShutdown) {
				try {
					if (!isPaused) {
						Runnable task = taskQueue.take();
						task.run();
						executedTasks++;
					} else {
						Thread.sleep(100); // Wait if paused
					}
				} catch (InterruptedException e) {
					Thread.currentThread().interrupt();
				}
			}
		}
	}

	public static void main(String[] args) throws InterruptedException {
		CustomThreadPool pool = new CustomThreadPool(5);

		pool.executeUntil(10);
		pool.pause();
		pool.resume();
		pool.executeUntil(5);
		pool.completeAllTasks();
	}
}
