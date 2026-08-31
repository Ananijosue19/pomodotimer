import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/providers/timer_provider.dart';
import '../../core/services/ambiance_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ambiance = Provider.of<AmbianceService>(context);
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Alertes & Sons", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text("Sons de notification"),
            subtitle: const Text("Jouer un son à la fin de chaque session"),
            value: timerProvider.soundEnabled,
            activeColor: Colors.red,
            onChanged: (val) => timerProvider.toggleSound(val),
          ),
          
          const Divider(height: 40),
          
          const Text("Ambiance (Fichiers requis)", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildAmbianceTile(context, ambiance, "Aucun", AmbianceType.none, Remix.volume_mute_line),
          _buildAmbianceTile(context, ambiance, "Pluie", AmbianceType.rain, Remix.rainy_line),
          _buildAmbianceTile(context, ambiance, "Bruit Blanc", AmbianceType.whiteNoise, Remix.windy_line),
          _buildAmbianceTile(context, ambiance, "Forêt", AmbianceType.forest, Remix.leaf_line),
          
          const Divider(height: 40),
          
          const Text("Volume Ambiance", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Slider(
            value: ambiance.volume,
            activeColor: Colors.red,
            onChanged: (val) => ambiance.setVolume(val),
          ),
          
          const Divider(height: 40),
          
          const Text("Durée des sessions (min)", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildDurationTile(
            context, 
            "Concentration", 
            timerProvider.workMinutes, 
            (val) => timerProvider.updateDurations(work: val)
          ),
          _buildDurationTile(
            context, 
            "Pause courte", 
            timerProvider.shortBreakMinutes, 
            (val) => timerProvider.updateDurations(short: val)
          ),
          _buildDurationTile(
            context, 
            "Pause longue", 
            timerProvider.longBreakMinutes, 
            (val) => timerProvider.updateDurations(long: val)
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

  Widget _buildDurationTile(BuildContext context, String title, int currentMinutes, Function(int) onUpdate) {
    return ListTile(
      title: Text(title),
      trailing: Text("$currentMinutes min", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      onTap: () => _showDurationPicker(context, title, currentMinutes, onUpdate),
    );
  }

  void _showDurationPicker(BuildContext context, String title, int initialValue, Function(int) onUpdate) {
    int tempValue = initialValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("$tempValue minutes"),
                Slider(
                  value: tempValue.toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 59,
                  activeColor: Colors.red,
                  onChanged: (val) {
                    setDialogState(() => tempValue = val.toInt());
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              onUpdate(tempValue);
              Navigator.pop(context);
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }
}
