/*
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
*/

const shim = require('fabric-shim');

var Chaincode = class {
    // Initialize the chaincode
    async Init(stub) {
        console.info('Init executed');
        let ret = stub.getFunctionAndParameters();
        let args = ret.params;
        if (args.length !== 2) {
            return shim.error(
                'Incorrect Arguments. Expecting a key and a value pair'
            );
        }
        await stub.putState(args[0], Buffer.from(args[1]));
        return shim.success();
    }

    async Invoke(stub) {
        console.info('Invoke executed');

        let ret = stub.getFunctionAndParameters();
        let fn = ret.fcn;
        let args = ret.args;
        console.info('function=', fn);

        if (fn === 'set') {
            return await this.set(stub, args);
        } else {
            return await this.get(stub, args);
        }
    }

    async set(stub, args) {
        console.info('====== set method ======');

        if (args.length !== 2) {
            return shim.error(
                'set: Incorrect Arguments. Expecting a key and a value pair'
            );
        }

        // Execute PutState - overwrites the current value
        await stub.putState(args[0], Buffer.from(args[1]));

        return shim.success(Buffer.from(args[1]));
    }

    async get(stub, args) {
        console.info('====== get method ======');

        if (args.length !== 1) {
            return shim.error(
                'get: Incorrect Arguments. Expecting a key value here'
            );
        }
        let value = await stub.getState(args[0]);
        if (value === null) {
            return shim.error('Asset not found on Blockchain: ' + args[0]);
        }
        return shim.success(Buffer.from(value));
    }
};

console.info('Started chaincode');

shim.start(new Chaincode());
