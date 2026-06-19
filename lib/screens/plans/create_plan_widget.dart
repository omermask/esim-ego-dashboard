import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/plans_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';

class CreatePlanWidget extends StatefulWidget {
  final VoidCallback onBack;
  const CreatePlanWidget({super.key, required this.onBack});

  @override
  State<CreatePlanWidget> createState() => _CreatePlanWidgetState();
}

class _CreatePlanWidgetState extends State<CreatePlanWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dataCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _priceUsdCtrl = TextEditingController();
  final _priceIqdCtrl = TextEditingController();
  final _markupCtrl = TextEditingController(text: '20');
  final _countriesCtrl = TextEditingController(text: 'all');
  final _bundleIdCtrl = TextEditingController();
  bool _isActive = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _dataCtrl.dispose();
    _durationCtrl.dispose();
    _priceUsdCtrl.dispose();
    _priceIqdCtrl.dispose();
    _markupCtrl.dispose();
    _countriesCtrl.dispose();
    _bundleIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'data_amount_mb': int.parse(_dataCtrl.text.trim()),
      'duration_days': int.parse(_durationCtrl.text.trim()),
      'price_usd': double.parse(_priceUsdCtrl.text.trim()),
      'price_iqd': int.parse(_priceIqdCtrl.text.trim()),
      'markup_percentage': double.parse(_markupCtrl.text.trim()),
      'countries': _countriesCtrl.text.trim(),
      'provider_bundle_id': _bundleIdCtrl.text.trim(),
      'is_active': _isActive,
    };
    final err = await context.read<PlansProvider>().create(data);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err != null) {
      CustomToaster.showError(context, message: err);
    } else {
      CustomToaster.showSuccess(context, message: trans(context, 'Plan created successfully'));
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: rs(context, 24)),
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: EdgeInsets.all(rs(context, 8)),
                  decoration: BoxDecoration(
                    color: dc.iconBox.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(rs(context, 10)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new, color: dc.textPrimary, size: rs(context, 16)),
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Text(trans(context, 'Create Plan'), style: TextStyle(
                fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 24)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(rs(context, 14)),
            decoration: BoxDecoration(
              color: dc.bg,
              borderRadius: BorderRadius.circular(rs(context, 20)),
              border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _svgIcon('assets/icons/wallet_add_icon_241828.svg', rs(context, 18), dc.primaryBtn),
                      SizedBox(width: rs(context, 8)),
                      Text(trans(context, 'Plan Details'), style: TextStyle(
                        fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
                      )),
                    ],
                  ),
                  SizedBox(height: rs(context, 14)),
                  _buildField(trans(context, 'Name'), _nameCtrl, hint: 'My Plan', required: true),
                  SizedBox(height: rs(context, 10)),
                  _buildField(trans(context, 'Description'), _descCtrl, hint: trans(context, 'Optional description'), maxLines: 2),
                  SizedBox(height: rs(context, 10)),
                  _buildField(trans(context, 'Data (MB)'), _dataCtrl, hint: '1024', keyboardType: TextInputType.number, required: true),
                  SizedBox(height: rs(context, 10)),
                  _buildField(trans(context, 'Duration (days)'), _durationCtrl, hint: '30', keyboardType: TextInputType.number, required: true),
                  SizedBox(height: rs(context, 10)),
                  Row(
                    children: [
                      Expanded(child: _buildField(trans(context, 'Price USD'), _priceUsdCtrl, hint: '1.99', keyboardType: const TextInputType.numberWithOptions(decimal: true), required: true)),
                      SizedBox(width: rs(context, 10)),
                      Expanded(child: _buildField(trans(context, 'Price IQD'), _priceIqdCtrl, hint: '3000', keyboardType: TextInputType.number, required: true)),
                    ],
                  ),
                  SizedBox(height: rs(context, 10)),
                  _buildField('${trans(context, 'Markup')} (%)', _markupCtrl, hint: '20', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  SizedBox(height: rs(context, 10)),
                  _buildField(trans(context, 'Countries'), _countriesCtrl, hint: 'all'),
                  SizedBox(height: rs(context, 10)),
                  _buildField(trans(context, 'Provider Bundle ID'), _bundleIdCtrl, required: true),
                  SizedBox(height: rs(context, 14)),
                  Row(
                    children: [
                      Text(trans(context, 'Active'), style: TextStyle(
                        fontSize: rs(context, 14), color: dc.textPrimary, fontWeight: FontWeight.w500,
                      )),
                      SizedBox(width: rs(context, 10)),
                      Switch(
                        value: _isActive,
                        activeTrackColor: dc.primaryBtn,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ],
                  ),
                  SizedBox(height: rs(context, 20)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dc.primaryBtn,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                      ),
                      child: _submitting
                        ? SizedBox(
                            width: rs(context, 20), height: rs(context, 20),
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(trans(context, 'Create Plan'), style: TextStyle(
                            fontSize: rs(context, 15), fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String? hint, bool required = false, TextInputType? keyboardType, int maxLines = 1}) {
    final dc = context.dialogColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label${required ? ' *' : ''}', style: TextStyle(
          fontSize: rs(context, 12), color: dc.textSecondary, fontWeight: FontWeight.w500,
        )),
        SizedBox(height: rs(context, 6)),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: rs(context, 14), color: dc.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: dc.textSecondary.withValues(alpha: 0.5), fontSize: rs(context, 13)),
            filled: true,
            fillColor: dc.iconBox.withValues(alpha: 0.3),
            contentPadding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 12)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 10)),
              borderSide: BorderSide(color: dc.borderColor.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 10)),
              borderSide: BorderSide(color: dc.borderColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 10)),
              borderSide: BorderSide(color: dc.accent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 10)),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? trans(context, 'Required') : null : null,
        ),
      ],
    );
  }

  Widget _svgIcon(String path, double size, Color color) {
    return SizedBox(
      width: size, height: size,
      child: SvgPicture.asset(path, width: size, height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
