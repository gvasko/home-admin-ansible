# home-admin-ansible

Ansible project scaffold for home administration tasks.

## Structure

- `ansible.cfg` - Ansible configuration
- `inventory.yaml` - Host inventory
- `playbooks/nvrs.yml` - Main NVR playbook
- `roles/common/tasks/main.yml` - Common role tasks
- `group_vars/all.yml` - Global variables

## Usage

Run the NVR playbook:

```bash
ansible-playbook playbooks/nvrs.yml
```
