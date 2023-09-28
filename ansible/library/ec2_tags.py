#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2020, Sergio Rua <sergio.rua@digitalis.io>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
TBD
'''

RETURN = '''
changed:
    description: Returns tags for this instance without using boto3
    type: str
    returned: always
'''
import json
import os
import tempfile
import requests

from ansible.module_utils import basic
from ansible.module_utils._text import to_bytes, to_native
from ansible.module_utils.basic import AnsibleModule

def get_tags(name=None):
    headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
    }

    url = "http://169.254.169.254/latest/meta-data/tags/instance/"
    if name:
      url = "http://169.254.169.254/latest/meta-data/tags/instance/%s" % (name)

    try:
        ret = requests.get(url, headers=headers)
    except requests.exceptions.Timeout:
        return 'Timeout', None
    except requests.exceptions.TooManyRedirects:
        return 'Too many redirects', None
    except requests.exceptions.RequestException as e:
        return str(e), None

    if ret.status_code == 404:
        return None
    if name:
        return {name: ret.content.split()[0].decode('utf-8')}
    tags = {}
    for t in ret.content.split():
        t = t.decode('utf-8')
        tags[t] = get_tags(t)[t]
    return tags

def module_main():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        instance_id=dict(type='str', required=False, default=""),
        name=dict(type='str', required=False, default="")
    )
    result = dict(
        changed=False,
        message='',
        config=''
    )
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )
    # exit if --check
    if module.check_mode:
        module.exit_json(**result)

    # Exit
    result['message'] = 'There you are'
    result['tags'] = get_tags(module.params['name'])
    result['changed'] = True
    module.exit_json(**result)

def main():
    module_main()

if __name__ == '__main__':
    main()