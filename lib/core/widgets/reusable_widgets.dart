import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class SyncSphereButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  
  const SyncSphereButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isText = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isText) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? DesignTokens.primaryColor,
          minimumSize: Size(width ?? double.infinity, 48),
        ),
        child: _buildChild(theme),
      );
    }
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? DesignTokens.primaryColor,
          side: BorderSide(color: backgroundColor ?? DesignTokens.primaryColor),
          minimumSize: Size(width ?? double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusM),
        ),
        child: _buildChild(theme),
      );
    }
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? DesignTokens.primaryColor,
        foregroundColor: textColor ?? DesignTokens.textInverse,
        minimumSize: Size(width ?? double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusM),
      ),
      child: _buildChild(theme),
    );
  }
  
  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isOutlined || isText 
              ? (textColor ?? DesignTokens.primaryColor)
              : DesignTokens.textInverse,
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: DesignTokens.spacingS),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      );
    }
    
    return Text(label, style: theme.textTheme.labelLarge);
  }
}

class SyncSphereCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool hasShadow;
  
  const SyncSphereCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(0),
      elevation: hasShadow ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.radiusL,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(DesignTokens.spacingM),
          child: child,
        ),
      ),
    );
  }
}

class SyncSphereInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  
  const SyncSphereInputField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: DesignTokens.spacingS),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          focusNode: focusNode,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData icon;
  
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionPressed,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: DesignTokens.textHint,
            ),
            const SizedBox(height: DesignTokens.spacingL),
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: DesignTokens.spacingL),
              SyncSphereButton(
                label: actionLabel!,
                onPressed: onActionPressed,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}