package de.grnx.parser;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.concurrent.CountDownLatch;


	public class SwingDialog extends JFrame {
	    private JLabel label1, label2, label3, label4;
	    private JTextField textField1, textField2, textField3, textField4;
	    private JButton button;
	    private JTabbedPane tabbedPane;
	    private JCheckBox checkBox;

	    private String documentPath;
	    private String batchFilePath;
	    private String newBatchName;
	    private int delay;
	    private boolean checkBoxValue;
	    private final CountDownLatch latch;

	    public SwingDialog(CountDownLatch latch) {
	        this.latch = latch;
	        tabbedPane = new JTabbedPane();

	        // Section 1
	        JPanel section1 = new JPanel();
	        section1.setLayout(new GridLayout(6, 2)); 

	        label1 = new JLabel("Document Path:");
	        textField1 = new JTextField(20);
	        section1.add(label1);
	        section1.add(textField1);

	        label2 = new JLabel("Batch File Path:");
	        textField2 = new JTextField(20);
	        section1.add(label2);
	        section1.add(textField2);

	        label3 = new JLabel("New Batch Name:");
	        textField3 = new JTextField(20);
	        section1.add(label3);
	        section1.add(textField3);

	        label4 = new JLabel("Delay (milliseconds):");
	        textField4 = new JTextField(20);
	        section1.add(label4);
	        section1.add(textField4);

	        checkBox = new JCheckBox("Enable Delayed Expansion");
	        section1.add(new JLabel(""));
	        section1.add(checkBox);

	        button = new JButton("Parse");
	        section1.add(new JLabel(""));
	        section1.add(button);

	        tabbedPane.addTab("Setup", section1);

	        add(tabbedPane);

	        button.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent e) {
	                documentPath = textField1.getText();
	                batchFilePath = textField2.getText();
	                newBatchName = textField3.getText().isBlank() ? "newBatch.bat" : textField3.getText();
	                delay = 5000;
	                checkBoxValue = checkBox.isSelected();

	                if (documentPath.equals("") || batchFilePath.equals("")) {
	                    JOptionPane.showMessageDialog(SwingDialog.this,
	                            "Document path and batch file path cannot be empty.");
	                } else {
	                    try {
	                        if (!textField4.getText().equals("")) {
	                            delay = Integer.parseInt(textField4.getText());
	                        }
	                        /*
							 * Main.data = null; Main.numberOfLines = 0; Main.checkedLines = 0;
							 * Main.parsedLines = 0; Main.data = new
							 * String[Main.countLines(documentPath)][4]; Main.parseDocument(documentPath,
							 * batchFilePath, newBatchName); System.out.println("100% reached!!");
							 * Main.rearGuard(batchFilePath, newBatchName); // Section 2 JPanel section2 =
							 * new JPanel(new BorderLayout()); ProgressBar progressBar = new ProgressBar();
							 * Vcollector TC = new Vcollector(Main.data); section2.setLayout(new
							 * BorderLayout()); section2.add(progressBar.pG, BorderLayout.NORTH);
							 * section2.add(new JScrollPane(TC.table), BorderLayout.CENTER);
							 * tabbedPane.addTab("Section 2", section2); tabbedPane.setSelectedIndex(1); //
							 * Switch to Section 2 after submission
							 * 
							 * updateArgsArray(); // Call method to update args array
							 */
	                        latch.countDown(); // Count down the latch to unblock the waiting thread

	                    } catch (NumberFormatException ex) {
	                        JOptionPane.showMessageDialog(SwingDialog.this, "Delay should be a valid integer.");
	                    }
	                }
	            }
	        });
	    
	        setTitle("Batch Text Recreator");
	        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	        pack();
	        setLocationRelativeTo(null);
	    }
	

	/*private void updateArgsArray() {
		Main.data = null;
		Main.numberOfLines = 0;
		Main.checkedLines = 0;
		Main.parsedLines = 0;
		Main.data = new String[Main.countLines(documentPath)][4];
		Main.parseDocument(documentPath, batchFilePath, newBatchName);
		Main.rearGuard(batchFilePath, newBatchName);
	}*/

	public String[] getArgsArray() {
        return new String[]{documentPath, batchFilePath, newBatchName, String.valueOf(delay), String.valueOf(checkBoxValue)};
        }
}