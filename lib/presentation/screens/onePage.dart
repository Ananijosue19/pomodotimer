import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/providers/timer_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/ambiance_service.dart';

class Onepage extends StatelessWidget {
  const Onepage({super.key});

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
                    color: Colors.red.withOpacity(0.1),
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
                          ? "FOCUS" : "PAUSE",
                        style: const TextStyle(
                          letterSpacing: 2,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
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
                      // Skip session logic
                    },
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
                          subtitle: Text("${task.completedPomodoros}/${task.estimatedPomodoros} Pomos"),
                          leading: Radio<String?>(
                            value: task.id,
                            groupValue: provider.selectedTask?.id,
                            onChanged: (val) {
                              provider.selectTask(val);
                              Navigator.pop(context);
                            },
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle Tâche"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nom de la tâche"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.addTask(controller.text);
                Navigator.pop(context);
                setModalState(() {});
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }
}

class Twopage extends StatelessWidget {
  const Twopage({super.key});

  @override
  Widget build(BuildContext context) {
    final ambiance = Provider.of<AmbianceService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Ambiance Sonore", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildAmbianceTile(context, ambiance, "Aucun", AmbianceType.none, Remix.volume_mute_line),
          _buildAmbianceTile(context, ambiance, "Pluie", AmbianceType.rain, Remix.rainy_line),
          _buildAmbianceTile(context, ambiance, "Bruit Blanc", AmbianceType.whiteNoise, Remix.windy_line),
          _buildAmbianceTile(context, ambiance, "Forêt", AmbianceType.forest, Remix.leaf_line),
          
          const Divider(height: 40),
          
          const Text("Volume", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Slider(
            value: ambiance.volume,
            activeColor: Colors.red,
            onChanged: (val) => ambiance.setVolume(val),
          ),
          
          const Divider(height: 40),
          
          const Text("Durée des sessions", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const ListTile(
            title: Text("Focus"),
            trailing: Text("25 min"),
          ),
          const ListTile(
            title: Text("Pause courte"),
            trailing: Text("5 min"),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbianceTile(BuildContext context, AmbianceService service, String title, AmbianceType type, IconData icon) {
    final isSelected = service.currentType == type;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.red : Colors.grey),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.red : Colors.black)),
      trailing: isSelected ? const Icon(Remix.check_line, color: Colors.red) : null,
      onTap: () => service.setAmbiance(type),
    );
  }
}

class ThreePage extends StatelessWidget {
  const ThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildStatCard(
              "Niveau", 
              userProvider.level.toString(), 
              Remix.flashlight_line, 
              Colors.blue
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              "Série Actuelle", 
              "${userProvider.streak} Jours", 
              Remix.fire_line, 
              Colors.orange
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              "Total Pomodoros", 
              userProvider.totalPomodoros.toString(), 
              Remix.timer_line, 
              Colors.red
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              "Expérience Totale", 
              "${userProvider.xp} XP", 
              Remix.star_line, 
              Colors.yellow[700]!
            ),
            const SizedBox(height: 30),
            const Text("Prochain Niveau", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: userProvider.levelProgress,
              minHeight: 15,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 5),
            Text("${(userProvider.levelProgress * 100).toInt()}%"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
