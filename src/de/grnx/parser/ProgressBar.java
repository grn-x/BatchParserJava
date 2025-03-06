package de.grnx.parser;

import java.awt.*;

import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.SwingUtilities;

public class ProgressBar extends JComponent {
	JPanel pG = new JPanel();
	static JProgressBar barParsedLines = new JProgressBar(0, 100);
	static JProgressBar barCheckedLines = new JProgressBar(0, 100);

	public ProgressBar() {
		pG.setLayout(new GridLayout(2, 1));
		pG.add(barParsedLines);
		pG.add(barCheckedLines);

		barParsedLines.setValue(0);
		barParsedLines.setStringPainted(true);
//        barParsedLines.setFont(new Font("MV Boli", Font.BOLD, 25));
//        barParsedLines.setForeground(Color.blue);
//        barParsedLines.setBackground(Color.black);

		barCheckedLines.setValue(0);
		barCheckedLines.setStringPainted(true);
//        barCheckedLines.setFont(new Font("MV Boli", Font.BOLD, 25));
//        barCheckedLines.setForeground(Color.red);
//        barCheckedLines.setBackground(Color.black);

		// loop();
	}

	public static void loop() {
		new Thread(() -> {
			while ((Main.numberOfLines >= Main.parsedLines) || (Main.numberOfLines >= Main.checkedLines)) {
				SwingUtilities.invokeLater(() -> update());
			}
		}).start();
	}

	public static void update() {
		barParsedLines.setMaximum(Main.numberOfLines);
		barParsedLines.setValue(Main.parsedLines);

		barCheckedLines.setMaximum(Main.numberOfLines);
		barCheckedLines.setValue(Main.checkedLines);

//        System.out.println(Main.numberOfLines);
//        System.out.println(Main.parsedLines);
//        System.out.println(Main.checkedLines);
	}

}
