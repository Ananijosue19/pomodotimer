import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/providers/timer_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../data/models/task_model.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // Header with Streak and XP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Remix.fire_fill, color: Colors.orange),
                      const SizedBox(width: 5),
                      Text('${userProvider.streak} Jours', 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Remix.flashlight_fill, color: Colors.yellow),
                      const SizedBox(width: 5),
                      Text('Niv. ${userProvider.level}', 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Task Selector
              GestureDetector(
                onTap: () => _showTaskPicker(context, taskProvider),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.checkbox_circle_line, 
                        color: taskProvider.selectedTask != null ? Colors.red : Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        taskProvider.selectedTask?.title ?? "Choisir une tâche",
                        style: TextStyle(
                          color: taskProvider.selectedTask != null ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Custom Circular Timer
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: timerProvider.progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerProvider.timerString,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timerProvider.currentSession == SessionType.focus 
                          ? "CONCENTRATION" : (timerProvider.currentSession == SessionType.shortBreak ? "PAUSE COURTE" : "PAUSE LONGUE"),
                        style: const TextStyle(
                          letterSpacing: 2,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Pomodoro cycle indicators
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(4, (index) {
                          int completedInCycle = timerProvider.completedPomodorosInCycle % 4;
                          if (timerProvider.completedPomodorosInCycle > 0 && completedInCycle == 0 && timerProvider.currentSession != SessionType.focus) {
                             completedInCycle = 4;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              index < completedInCycle ? Remix.checkbox_blank_circle_fill : Remix.checkbox_blank_circle_line,
                              size: 12,
                              color: Colors.red.withValues(alpha: 0.5),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Remix.refresh_line, size: 30),
                    onPressed: () => timerProvider.resetTimer(),
                    tooltip: "Réinitialiser",
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      if (timerProvider.isRunning) {
                        timerProvider.pauseTimer();
                      } else {
                        timerProvider.startTimer();
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.red,
                      child: Icon(
                        timerProvider.isRunning ? Remix.pause_fill : Remix.play_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Remix.skip_forward_fill, size: 30),
                    onPressed: () {
                      // Skip logic
                    },
                    tooltip: "Passer",
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskPicker(BuildContext context, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Mes Tâches", 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Remix.add_line),
                        onPressed: () => _showAddTaskDialog(context, provider, setModalState),
                      ),
                    ],
                  ),
                  const Divider(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = provider.tasks[index];
                        return ListTile(
                          title: Text(task.title),
                          subtitle: Text("${task.completedPomodoros}/${task.estimatedPomodoros} Pomos • ${task.category.name}"),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: task.category.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Radio<String?>(
                                value: task.id,
                                groupValue: provider.selectedTask?.id,
                                onChanged: (val) {
                                  provider.selectTask(val);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Remix.delete_bin_line, size: 20),
                            onPressed: () {
                              provider.deleteTask(task.id);
                              setModalState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider provider, Function setModalState) {
    final controller = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.autre;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Nouvelle Tâche"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Nom de la tâche"),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Catégorie :", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: TaskCategory.values.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedCategory = cat),
                      child: Chip(
                        label: Text(cat.name, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
                        backgroundColor: isSelected ? cat.color : cat.color.withValues(alpha: 0.1),
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    provider.addTask(controller.text, category: selectedCategory);
                    Navigator.pop(context);
                    setModalState(() {});
                  }
                },
                child: const Text("Ajouter"),
              ),
            ],
          );
        },
      ),
    );
  }
}
