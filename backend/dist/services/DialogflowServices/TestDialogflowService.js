"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const Yup = __importStar(require("yup"));
const AppError_1 = __importDefault(require("../../errors/AppError"));
const QueryDialogflowService_1 = require("./QueryDialogflowService");
const CreateDialogflowSessionService_1 = require("./CreateDialogflowSessionService");
const TestDialogflowSession = async ({ projectName, jsonContent, language }) => {
    const schema = Yup.object().shape({
        projectName: Yup.string().required().min(2),
        jsonContent: Yup.string().required(),
        language: Yup.string().required().min(2)
    });
    try {
        await schema.validate({ projectName, jsonContent, language });
    }
    catch (err) {
        throw new AppError_1.default(err.message);
    }
    const session = await (0, CreateDialogflowSessionService_1.createDialogflowSession)(999, projectName, jsonContent);
    if (!session) {
        throw new AppError_1.default("ERR_TEST_SESSION_DIALOG", 400);
    }
    let dialogFlowReply = await (0, QueryDialogflowService_1.queryDialogFlow)(session, projectName, "TestSession", "Ola", language, undefined);
    await session.close();
    if (!dialogFlowReply) {
        throw new AppError_1.default("ERR_TEST_REPLY_DIALOG", 400);
    }
    const messages = [];
    for (let message of dialogFlowReply.responses) {
        messages.push(message.text.text[0]);
    }
    return { messages };
};
exports.default = TestDialogflowSession;
