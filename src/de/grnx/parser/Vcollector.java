package de.grnx.parser;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableCellRenderer;
import java.awt.*;
import java.util.ArrayList;

public class Vcollector extends JComponent {
	static JTable table;
	static DefaultTableModel model;

//    TableConverter(ArrayList<ArrayList<String>> data) {
	Vcollector(String[][] data) {
		displayDataInTable(data);
	}

//    private void displayDataInTable(ArrayList<ArrayList<String>> data) {
	private void displayDataInTable(String[][] data) {
		model = new DefaultTableModel() {
			@Override
			public Class<?> getColumnClass(int columnIndex) {
				return String.class;
			}
		};
		model.addColumn("Creating Line");
		model.addColumn("CMD Executed Line");
		model.addColumn("Expected Line");
		model.addColumn("Batch Executed Line");

//        for (ArrayList<String> row : data) {
		for (String[] row : data) {
			model.addRow(row);
//            model.addRow(row.toArray());
		}

		table = new JTable(model) {
			@Override
			public Component prepareRenderer(TableCellRenderer renderer, int row, int column) {
				Component component = super.prepareRenderer(renderer, row, column);

				String value1 = getValueAt(row, 1) != null ? getValueAt(row, 1).toString() : "";
				String value2 = getValueAt(row, 2) != null ? getValueAt(row, 2).toString() : "";
				if (!value1.equals(value2)) {
					component.setBackground(Color.lightGray);
				} else {
					component.setBackground(Color.WHITE);
				}

				String value3 = getValueAt(row, 3) != null ? getValueAt(row, 3).toString() : "";
				if (!value3.equals(value2) && !value3.isBlank()) {
					component.setBackground(Color.RED);
				}
				return component;
			}
		};

		table.getTableHeader().setReorderingAllowed(false);
	}

//    public static boolean update(ArrayList<ArrayList<String>> data) {
	public static boolean update(String[][] data) {
		boolean[] Flag = { false };
		SwingUtilities.invokeLater(() -> {

			model.setRowCount(0);

			for (String[] row : data) {
				model.addRow(row);
			}

			table.setModel(model);

			table.repaint();
			Flag[0] = true;
		});
		return Flag[0];

	}

	public static boolean update() {
		boolean[] Flag = { false };
		SwingUtilities.invokeLater(() -> {

			model.setRowCount(0);

//            for (ArrayList<String> row : Main.data) {
			for (String[] row : Main.data) {
//                model.addRow(row.toArray()); // Add new rows
				model.addRow(row);
			}
			table.setModel(model);

			table.repaint();
			Flag[0] = true;
		});
		return Flag[0];

	}

	public JTable getTable() {
		return table;
	}
}
