abstract class PartnerPrivilegeEvent {
  const PartnerPrivilegeEvent();
}

class PartnerPrivilegeStarted extends PartnerPrivilegeEvent {
  const PartnerPrivilegeStarted();
}

class PartnerPageChanged extends PartnerPrivilegeEvent {
  final int index;

  const PartnerPageChanged(this.index);
}
