// lib/features/tasks/presentation/screens/add_edit_task_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/task.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? existingTask; // null = Thêm mới, không null = Chỉnh sửa
  final String? parentId;     // ID của task cha nếu đang thêm task con

  const AddEditTaskScreen({super.key, this.existingTask, this.parentId});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  TaskPriority _selectedPriority = TaskPriority.low;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị form nếu là chế độ chỉnh sửa
    _titleController = TextEditingController(text: widget.existingTask?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existingTask?.description ?? '');
    _selectedPriority = widget.existingTask?.priority ?? TaskPriority.low;
    _startDate = widget.existingTask?.startDate;
    _endDate = widget.existingTask?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = (isStartDate ? _startDate : _endDate) ?? DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (newDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = newDate;
        } else {
          _endDate = newDate;
        }
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = context.read<TaskProvider>();
      final title = _titleController.text.trim();

      if (_isEditing) {
        // Chế độ Cập nhật
        taskProvider.updateTask(widget.existingTask!.id, {
          'title': title,
          'parentId': widget.parentId,
          'description': _descriptionController.text.trim(),
          'priority': _selectedPriority.name,
          'startDate': _startDate != null ? Timestamp.fromDate(_startDate!) : null,
          'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
        });
      } else {
        // Chế độ Thêm mới
        taskProvider.addTask(
          title: title,
          parentId: widget.parentId,
          priority: _selectedPriority,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa Công việc' : 'Thêm Công việc mới'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên công việc'),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên công việc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết', alignLabelWithHint: true),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              // Chỉ hiển thị các lựa chọn này cho công việc gốc
              if (widget.parentId == null) ...[
                DropdownButtonFormField<TaskPriority>(
                  value: _selectedPriority,
                  items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                  onChanged: (v) => setState(() => _selectedPriority = v!),
                  decoration: const InputDecoration(labelText: 'Độ ưu tiên'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_startDate == null ? 'Ngày bắt đầu' : DateFormat('dd/MM/yyyy').format(_startDate!)),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.event),
                        label: Text(_endDate == null ? 'Ngày kết thúc' : DateFormat('dd/MM/yyyy').format(_endDate!)),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}