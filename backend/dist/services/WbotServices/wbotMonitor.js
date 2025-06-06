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
const Sentry = __importStar(require("@sentry/node"));
const Contact_1 = __importDefault(require("../../models/Contact"));
const Setting_1 = __importDefault(require("../../models/Setting"));
const Ticket_1 = __importDefault(require("../../models/Ticket"));
const logger_1 = require("../../utils/logger");
const CreateOrUpdateBaileysService_1 = __importDefault(require("../BaileysServices/CreateOrUpdateBaileysService"));
const CreateMessageService_1 = __importDefault(require("../MessageServices/CreateMessageService"));
const Debounce_1 = require("../../helpers/Debounce");
const wbotMonitor = async (wbot, whatsapp, companyId) => {
    try {
        wbot.ev.on("call", async (call) => {
            try {
                if (call.length > 0) {
                    const sendMsgCall = await Setting_1.default.findOne({
                        where: { key: "call", companyId }
                    });
                    if (sendMsgCall.value === "disabled") {
                        const callId = call[0].id;
                        const from = call[0].from;
                        await wbot.rejectCall(callId, from).then(async () => {
                            const debouncedSentMessage = (0, Debounce_1.debounce)(async () => {
                                await wbot.sendMessage(from, {
                                    text: `*Mensagem Automática:*\nAs chamadas de voz e vídeo estão desabilitadas para este WhatsApp. Por favor, envie uma mensagem de texto.`
                                });
                                const number = from.split(":").shift();
                                const contact = await Contact_1.default.findOne({
                                    where: { companyId, number }
                                });
                                const ticket = await Ticket_1.default.findOne({
                                    where: {
                                        contactId: contact.id,
                                        whatsappId: wbot.id,
                                        //status: { [Op.or]: ["close"] },
                                        companyId
                                    }
                                });
                                // se não existir o ticket não faz nada.
                                if (!ticket)
                                    return;
                                const date = new Date();
                                const hours = date.getHours();
                                const minutes = date.getMinutes();
                                const body = `Chamada de voz/vídeo perdida às ${hours}:${minutes}`;
                                const messageData = {
                                    id: callId,
                                    ticketId: ticket.id,
                                    contactId: contact.id,
                                    body,
                                    fromMe: false,
                                    mediaType: "call_log",
                                    read: true,
                                    quotedMsgId: null,
                                    ack: 1
                                };
                                await ticket.update({
                                    lastMessage: body
                                });
                                if (ticket.status === "closed") {
                                    await ticket.update({
                                        status: "pending"
                                    });
                                }
                                await (0, CreateMessageService_1.default)({
                                    messageData,
                                    companyId: companyId
                                });
                            }, 3000, Number(callId.replace(/\D/g, "")));
                            debouncedSentMessage();
                        });
                    }
                }
            }
            catch (error) {
                logger_1.logger.error("Error handling call:", error);
            }
        });
        wbot.ev.on("contacts.upsert", async (contacts) => {
            await (0, CreateOrUpdateBaileysService_1.default)({
                whatsappId: whatsapp.id,
                contacts
            });
        });
    }
    catch (err) {
        Sentry.captureException(err);
        logger_1.logger.error(err);
    }
};
exports.default = wbotMonitor;
