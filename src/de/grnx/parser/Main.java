
package de.grnx.parser;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Container;
import java.awt.Desktop;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.LayoutManager;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.Scanner;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.swing.JFrame;
import javax.swing.JScrollPane;
import javax.swing.SwingUtilities;

public class Main {

//    public static volatile ArrayList<String[]> data = new ArrayList<>();
//    public static volatile ArrayList<ArrayList<String>> data = new ArrayList<>();
	public static volatile String[][] data;
	public static volatile int numberOfLines = 0;
	public static volatile int parsedLines = 0;
	public static volatile int checkedLines = 0;
	public static int delay = 2000;
	public static String documentPath;
	public static String batchFilePath;
	public static String newBatchName;
//    public static CustomThreadPool customThreadPool = new CustomThreadPool(Runtime.getRuntime().availableProcessors());
	public static CustomThreadPool customThreadPool = new CustomThreadPool(1);
//    public static ExecutorService customThreadPool = Executors.newFixedThreadPool (Runtime.getRuntime().availableProcessors());
	private static BufferedWriter fileWriter;

	public static String escapeBatchLine(String batchLine) {
		StringBuilder escapedLine = new StringBuilder();

		for (char c : batchLine.toCharArray()) {
			switch (c) {
			case '^':
			case '&':
			case '|':
			case '<':
			case '>':
			case '"':
			case ')':
			case '(':
				escapedLine.append('^');
				escapedLine.append(c);
				break;
			case '%':
				escapedLine.append('%');
				escapedLine.append(c);
				break;
			case '!':
				escapedLine.append('^');
				escapedLine.append('^');
				escapedLine.append(c);
				break;
			default:
				escapedLine.append(c);
				break;
			}
		}
		return escapedLine.toString();
	}

	public synchronized static void writeData(String s1, String s2, String s3, String s4, int line) {
//        data.add(new String[]{s1.strip(), s2.strip(), s3.strip(), s4.strip()});

//        data.add(new ArrayList<String>(List.of(s1.strip(), s2.strip(), s3.strip())));
		String[] newString = data[line];
		data[line] = new String[] { Optional.ofNullable(newString[0]).orElse(s1 != null ? s1.strip() : null),
				Optional.ofNullable(newString[1]).orElse(s2 != null ? s2.strip() : null),
				Optional.ofNullable(newString[2]).orElse(s3 != null ? s3.strip() : null),
				Optional.ofNullable(newString[3]).orElse(s4 != null ? s4.strip() : null) };
	}

	public static String executeCommand(String command) {
		try {
			ProcessBuilder builder = new ProcessBuilder("cmd.exe", "/c", command);
			builder.redirectErrorStream(true);
			Process process = builder.start();

			BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
			StringBuilder output = new StringBuilder();
			String line;
			while ((line = reader.readLine()) != null) {
				output.append(line).append(System.lineSeparator());
			}
			process.waitFor();
			reader.close();
			return output.toString();
		} catch (IOException | InterruptedException e) {
			e.printStackTrace();
			return null;
		}
	}

	public static void appendToBatchFile(BufferedWriter writer, String line, String initialLine, String newBatchName) {
		try {
			if (line.isBlank()) {
				String toWrite = "@(Echo. )>>" + newBatchName;
				writer.write(toWrite);
				writer.newLine();
			} else {
				String toWrite = "@(Echo " + line + ")>>" + newBatchName;
				writer.write(toWrite);
				writer.newLine();
				customThreadPool.submit(() -> {
					String write = toWrite;
					String str = line;
					try {
						writeData(write, executeCommand("Echo " + str), initialLine, null, checkedLines);
						synchronized (Main.class) {
							checkedLines++;
							SwingUtilities.invokeLater(ProgressBar::update);
							SwingUtilities.invokeLater(Vcollector::update);

						}
					} catch (Exception e) {
						e.printStackTrace();
					}
				});
				synchronized (Main.class) {
					parsedLines++;
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void parseDocument(String documentPath, String batchFilePath, String newBatchName) {
		try (BufferedReader reader = new BufferedReader(new FileReader(documentPath))) {
			fileWriter = new BufferedWriter(new FileWriter(batchFilePath, true));
			String line;
			while ((line = reader.readLine()) != null) {
				String escapedLine = escapeBatchLine(line);
				appendToBatchFile(fileWriter, escapedLine, line, newBatchName);
			}
			if (fileWriter != null) {
				fileWriter.close();
			}
			if (parsedLines == numberOfLines) {
				SwingUtilities.invokeLater(() -> {
					try {
						Desktop.getDesktop().open(new File(new File(batchFilePath).getParent()));
					} catch (Exception e) {
						e.printStackTrace();
					}
				});
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static int countLines(String documentPath) {
		try (BufferedReader reader = new BufferedReader(new FileReader(documentPath))) {
			String line;
			while ((line = reader.readLine()) != null) {
				if (!line.strip().isBlank())
					numberOfLines++;

			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return numberOfLines;
	}

	public static void main(String[] args) {

//		String command = System.getProperty("sun.java.command");
//		if (command.contains(".jar")) {
			// System.out.println("The JAR file was executed from the command line.");
			// Add your command line execution logic here

//do nothing

//		} else {
//    	            System.out.println("The JAR file was executed by double-clicking.");
			// Add your double-click execution logic here


//		}
		if(args.length==0) {
			CountDownLatch latch = new CountDownLatch(1);
			SwingDialog swingDialog = new SwingDialog(latch);
			swingDialog.setVisible(true);

			try {
				latch.await(); // Block the calling thread until countdown latch is zero
			} catch (InterruptedException e) {
				e.printStackTrace();
			}

			// Get the updated args array
			args = swingDialog.getArgsArray();
		}
		

		if (args.length == 2) {
			documentPath = args[0];
			batchFilePath = args[1];
			newBatchName = "newBatch.bat";
			delay = 5000;

		} else if (args.length == 3) {
			documentPath = args[0];
			batchFilePath = args[1];
			newBatchName = args[2];
			delay = 5000;
		} else if (args.length == 4) {
			documentPath = args[0];
			batchFilePath = args[1];
			newBatchName = args[2];
			try {
				delay = Integer.parseInt(args[3]);
			} catch (Exception e) {
				System.err.println(
						"Fourth argument is milliseconds as integer and used in checking stage to set the delay between the execution of the batch script and the reading of the new File");
			}
		} else if (args.length == 0) {
			
			documentPath = "\\append.bat";
			batchFilePath = "\\java.bat";
			newBatchName = "newBatch.bat";
			delay = 5000;
		} else {
			System.out.println("Usage: java Main <document_path> <batch_file_path> (optional)<batch_name>");
			return;
		}

		File documentFile = new File(documentPath);
		if (!documentFile.exists() || !documentFile.isFile()) {
			System.out.println("The specified document file does not exist or the path is invalid.");
			return;
		}

		SwingUtilities.invokeLater(() -> {
			JFrame frame = new JFrame("Progress Bar Example");
			frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
			ProgressBar progressBar = new ProgressBar();
			Vcollector TC;

			TC = new Vcollector(data);
//            frame.setLayout(new GridLayout(2, 1));
			frame.setLayout(new BorderLayout());
			frame.add(progressBar.pG, BorderLayout.NORTH);
			frame.add(new JScrollPane(TC.table), BorderLayout.CENTER);
			frame.pack();
			frame.setVisible(true);
		});

		data = new String[countLines(documentPath)][4];
		parseDocument(documentPath, batchFilePath, newBatchName);
		System.out.println("100% reached!!");
		// now
		rearGuard(batchFilePath, newBatchName);

		LocalTime start = LocalTime.now();
		System.out.println(Duration.between(start, LocalTime.now()).toMillis());
	}

	public static void rearGuard(String batchPath, String newBatchName) {
		Path tempDir;
		File createdBatchFile = new File(new File(batchPath).getParent() + File.separator + newBatchName);

		try {
			String osName = System.getProperty("os.name");
			if (osName != null && osName.startsWith("Windows")) {

				try {
					tempDir = Files.createTempDirectory("isolatedBatchExecution");
					tempDir.toFile().deleteOnExit();

					String fileName = new File(batchPath).getName();
					Path copiedFilePath = Files.copy(Path.of(batchPath), tempDir.resolve(fileName));
					String adjustedFilePath = copiedFilePath.toAbsolutePath().toString();

					// Desktop.getDesktop().open(new File(adjustedFilePath));
					int exit = Runtime.getRuntime().exec(
							"cmd /c cd " + tempDir + " && start " + new File(adjustedFilePath + " &&Exit").getName())
							.waitFor();
					System.out.println("Exit: " + exit);

					int index = 0;

					try {
						Thread.sleep(delay);

						try (BufferedReader resultReader = new BufferedReader(
								new FileReader(tempDir + "\\" + newBatchName))) {
							fileWriter = new BufferedWriter(new FileWriter(batchFilePath, true));
							String line;

//                                 while ((line = reader.readLine()) != null) {
							while ((line = resultReader.readLine()) != null) {
								// ArrayList<ArrayList<String>> data = new ArrayList<>();
								if (!line.toString().isBlank()) {
									writeData(null, null, null, line, index);
									SwingUtilities.invokeLater(Vcollector::update);

									index++;

								}

//                               	 System.out.println(Arrays.stream(data).flatMap(Arrays::stream).filter(s -> Arrays.asList(data).indexOf(s) % 3 == 0).collect(Collectors.joining(", ")));

							}
						}
					} catch (Exception e2) {
						e2.printStackTrace();
					}

					// tempDir.toFile().delete();
				} catch (Exception e) {
					e.printStackTrace();
				}

			} else {
				System.err.println("Unsupported operating system.");
				return;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		try {
			// createdBatchFile.delete();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}

/*
 * try (BufferedReader resultReader = new BufferedReader(new
 * FileReader(tempDir+"\\"+newBatchName))) { fileWriter = new BufferedWriter(new
 * FileWriter(batchFilePath, true)); String line;
 * 
 * while ((line = resultReader.readLine()) != null) {
 * //ArrayList<ArrayList<String>> data = new ArrayList<>();
 * if(!line.toString().isBlank()) { // data.get(index).add(line);
 * writeData(null, null, null, line, index);
 * SwingUtilities.invokeLater(Vcollector::update);
 * 
 * index++;
 * 
 * } // System.out.println(Arrays.stream(data).flatMap(Arrays::stream).filter(s
 * -> Arrays.asList(data).indexOf(s) % 3 ==
 * 0).collect(Collectors.joining(", ")));
 * 
 * 
 * 
 * }
 */

//String command = "cmd.exe /c \"" + batchPath.replace('\\', '/') + "\"";

//Process process = Runtime.getRuntime().exec(command);

// ProcessBuilder processBuilder = new ProcessBuilder("cmd.exe", "/c", adjustedFilePath);
// ProcessBuilder processBuilder = new ProcessBuilder("cmd /c cd "+tempDir+" && start "+new File(adjustedFilePath).getName());
/*
 * ProcessBuilder processBuilder = new ProcessBuilder("cmd /c exit");
 * processBuilder.redirectErrorStream(true); try { Process process =
 * processBuilder.start(); System.out.println("\"" +
 * createdBatchFile.getAbsolutePath() + "\"");
 * 
 * int exitCode = process.waitFor();
 * 
 * System.out.println("2\"" + createdBatchFile.getAbsolutePath() + "\"");
 * 
 * if (exitCode == 0) { System.out.println("Batch file executed successfully");
 * } else { System.out.println("Error: Batch file execution failed");
 * BufferedReader reader = new BufferedReader(new
 * InputStreamReader(process.getInputStream())); String line; while ((line =
 * reader.readLine()) != null) { System.out.println(line); } } // Add your
 * handling code here } catch (IOException e) { e.printStackTrace(); }
 */
//sorry für das fucking schlachtfeld

/*
 * Process process = Runtime.getRuntime().exec(command);
 * 
 * System.out.println("\"" + createdBatchFile.getAbsolutePath() + "\"");
 * 
 * int exitCode = process.waitFor();
 * 
 * System.out.println("2\"" + createdBatchFile.getAbsolutePath() + "\"");
 * 
 * if (exitCode == 0) { System.out.println("Batch file executed successfully");
 * } else { System.out.println("Error: Batch file execution failed");
 * BufferedReader reader = new BufferedReader(new
 * InputStreamReader(process.getInputStream())); String line; while ((line =
 * reader.readLine()) != null) { System.out.println(line); } }
 */

//Desktop desktop = Desktop.getDesktop();
//desktop.open(new File(batchPath));
//System.out.println("\"" + createdBatchFile.getAbsolutePath() + "\"");

//Process process = Runtime.getRuntime().exec("powershell.exe", "/c")

/*
 * Runtime rt = Runtime.getRuntime(); String[] commands = {"system.exe",
 * "-get t"}; System.out.println(command); Process proc = rt.exec(command);
 * 
 * BufferedReader stdInput = new BufferedReader(new
 * InputStreamReader(proc.getInputStream()));
 * 
 * BufferedReader stdError = new BufferedReader(new
 * InputStreamReader(proc.getErrorStream()));
 * 
 * // Read the output from the command
 * System.out.println("Here is the standard output of the command:\n"); String s
 * = null; while ((s = stdInput.readLine()) != null) { System.out.println(s); }
 * 
 * // Read any errors from the attempted command
 * System.out.println("Here is the standard error of the command (if any):\n");
 * while ((s = stdError.readLine()) != null) { System.out.println(s); }
 */
