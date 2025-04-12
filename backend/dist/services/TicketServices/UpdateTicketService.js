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
const moment_1 = __importDefault(require("moment"));
const Sentry = __importStar(require("@sentry/node"));
const CheckContactOpenTickets_1 = __importDefault(require("../../helpers/CheckContactOpenTickets"));
const SetTicketMessagesAsRead_1 = __importDefault(require("../../helpers/SetTicketMessagesAsRead"));
const socket_1 = require("../../libs/socket");
const Queue_1 = __importDefault(require("../../models/Queue"));
const ShowTicketService_1 = __importDefault(require("./ShowTicketService"));
const ShowWhatsAppService_1 = __importDefault(require("../WhatsappService/ShowWhatsAppService"));
const SendWhatsAppMessage_1 = __importDefault(require("../WbotServices/SendWhatsAppMessage"));
const FindOrCreateATicketTrakingService_1 = __importDefault(require("./FindOrCreateATicketTrakingService"));
const GetTicketWbot_1 = __importDefault(require("../../helpers/GetTicketWbot"));
const wbotMessageListener_1 = require("../WbotServices/wbotMessageListener");
const ListSettingsServiceOne_1 = __importDefault(require("../SettingServices/ListSettingsServiceOne"));
const ShowUserService_1 = __importDefault(require("../UserServices/ShowUserService"));
const lodash_1 = require("lodash");
const UpdateTicketService = async ({ ticketData, ticketId, companyId }) => {
    try {
        const { status } = ticketData;
        let { queueId, userId, whatsappId } = ticketData;
        let chatbot = ticketData.chatbot || false;
        let queueOptionId = ticketData.queueOptionId || null;
        const io = (0, socket_1.getIO)();
        const ticket = await (0, ShowTicketService_1.default)(ticketId, companyId);
        const ticketTraking = await (0, FindOrCreateATicketTrakingService_1.default)({
            ticketId,
            companyId,
            whatsappId: ticket.whatsappId
        });
        if ((0, lodash_1.isNil)(whatsappId)) {
            whatsappId = ticket.whatsappId?.toString();
        }
        await (0, SetTicketMessagesAsRead_1.default)(ticket);
        const oldStatus = ticket.status;
        const oldUserId = ticket.user?.id;
        const oldQueueId = ticket.queueId;
        if (oldStatus === "closed" ||
            (whatsappId && Number(whatsappId) !== ticket.whatsappId)) {
            await (0, CheckContactOpenTickets_1.default)(ticket.contact.id, whatsappId);
            chatbot = null;
            queueOptionId = null;
        }
        if (status === "closed") {
            const { complationMessage, ratingMessage } = ticket.whatsappId
                ? await (0, ShowWhatsAppService_1.default)(ticket.whatsappId, companyId)
                : { complationMessage: null, ratingMessage: null };
            const settingEvaluation = await (0, ListSettingsServiceOne_1.default)({
                companyId: companyId,
                key: "userRating"
            });
            if (settingEvaluation?.value === "enabled") {
                if (ticketTraking.ratingAt == null && ticketTraking.userId !== null) {
                    const bodyRatingMessage = `${ratingMessage ? ratingMessage + "\n\n" : ""}Digite de 1 a 5 para qualificar nosso atendimento:\n\n*5* - 😊 _Ótimo_\n*4* - 🙂 _Bom_\n*3* - 😐 _Neutro_\n*2* - 😕 _Ruim_\n*1* - 😞 _Péssimo_`;
                    await (0, SendWhatsAppMessage_1.default)({ body: bodyRatingMessage, ticket });
                    await ticketTraking.update({
                        ratingAt: (0, moment_1.default)().toDate()
                    });
                }
                ticketTraking.ratingAt = (0, moment_1.default)().toDate();
                ticketTraking.rated = false;
            }
            else {
                ticketTraking.finishedAt = (0, moment_1.default)().toDate();
                if (!(0, lodash_1.isNil)(complationMessage) && complationMessage !== "") {
                    const body = `\u200e${complationMessage}`;
                    await (0, SendWhatsAppMessage_1.default)({ body, ticket });
                }
            }
            await ticket.update({
                promptId: null,
                integrationId: null,
                useIntegration: false,
                typebotStatus: false,
                typebotSessionId: null
            });
            ticketTraking.whatsappId = ticket.whatsappId;
            ticketTraking.userId = ticket.userId;
        }
        if (queueId !== undefined && queueId !== null) {
            ticketTraking.queuedAt = (0, moment_1.default)().toDate();
        }
        const settingsTransfTicket = await (0, ListSettingsServiceOne_1.default)({
            companyId: companyId,
            key: "sendMsgTransfTicket"
        });
        if (settingsTransfTicket?.value === "enabled") {
            if (oldQueueId !== queueId &&
                oldUserId === userId &&
                !(0, lodash_1.isNil)(oldQueueId) &&
                !(0, lodash_1.isNil)(queueId)) {
                const queue = await Queue_1.default.findByPk(queueId);
                const wbot = await (0, GetTicketWbot_1.default)(ticket);
                const msgtxt = `*Mensagem automática*:\nVocê foi transferido para o departamento *${queue?.name}*\nAguarde um momento, por favor. Iremos te atender em breve!`;
                const queueChangedMessage = await wbot.sendMessage(`${ticket.contact.number}@${ticket.isGroup ? "g.us" : "s.whatsapp.net"}`, { text: msgtxt });
                await (0, wbotMessageListener_1.verifyMessage)(queueChangedMessage, ticket, ticket.contact);
            }
            else if (oldUserId !== userId &&
                oldQueueId === queueId &&
                !(0, lodash_1.isNil)(oldUserId) &&
                !(0, lodash_1.isNil)(userId)) {
                const wbot = await (0, GetTicketWbot_1.default)(ticket);
                const nome = await (0, ShowUserService_1.default)(ticketData.userId);
                const msgtxt = `*Mensagem automática*:\nVocê foi transferido para o atendente *${nome.name}*.\nAguarde um momento, por favor. Iremos te atender em breve!`;
                const queueChangedMessage = await wbot.sendMessage(`${ticket.contact.number}@${ticket.isGroup ? "g.us" : "s.whatsapp.net"}`, { text: msgtxt });
                await (0, wbotMessageListener_1.verifyMessage)(queueChangedMessage, ticket, ticket.contact);
            }
            else if (oldUserId !== userId &&
                !(0, lodash_1.isNil)(oldUserId) &&
                !(0, lodash_1.isNil)(userId) &&
                oldQueueId !== queueId &&
                !(0, lodash_1.isNil)(oldQueueId) &&
                !(0, lodash_1.isNil)(queueId)) {
                const wbot = await (0, GetTicketWbot_1.default)(ticket);
                const queue = await Queue_1.default.findByPk(queueId);
                const nome = await (0, ShowUserService_1.default)(ticketData.userId);
                const msgtxt = `*Mensagem automática*:\nVocê foi transferido para o departamento *${queue?.name}* e será atendido por *${nome.name}*.\nAguarde um momento, por favor. Iremos te atender em breve!`;
                const queueChangedMessage = await wbot.sendMessage(`${ticket.contact.number}@${ticket.isGroup ? "g.us" : "s.whatsapp.net"}`, { text: msgtxt });
                await (0, wbotMessageListener_1.verifyMessage)(queueChangedMessage, ticket, ticket.contact);
            }
            else if (oldUserId !== undefined &&
                (0, lodash_1.isNil)(userId) &&
                oldQueueId !== queueId &&
                !(0, lodash_1.isNil)(queueId)) {
                const queue = await Queue_1.default.findByPk(queueId);
                const wbot = await (0, GetTicketWbot_1.default)(ticket);
                const msgtxt = `*Mensagem automática*:\nVocê foi transferido para o departamento *${queue?.name}*\nAguarde um momento, por favor. Iremos te atender em breve!`;
                const queueChangedMessage = await wbot.sendMessage(`${ticket.contact.number}@${ticket.isGroup ? "g.us" : "s.whatsapp.net"}`, { text: msgtxt });
                await (0, wbotMessageListener_1.verifyMessage)(queueChangedMessage, ticket, ticket.contact);
            }
        }
        await ticket.update({
            status,
            queueId,
            userId,
            whatsappId,
            chatbot,
            queueOptionId
        });
        await ticket.reload();
        if (status === "pending") {
            await ticketTraking.update({
                whatsappId,
                queuedAt: (0, moment_1.default)().toDate(),
                startedAt: null,
                userId: null
            });
        }
        if (status === "open") {
            await ticketTraking.update({
                startedAt: (0, moment_1.default)().toDate(),
                ratingAt: null,
                rated: false,
                whatsappId,
                userId: ticket.userId
            });
        }
        await ticketTraking.save();
        if (ticket.status !== oldStatus || ticket.user?.id !== oldUserId) {
            io.to(oldStatus).emit(`company-${companyId}-ticket`, {
                action: "delete",
                ticketId: ticket.id
            });
        }
        io.to(ticket.status)
            .to("notification")
            .to(ticketId.toString())
            .emit(`company-${companyId}-ticket`, {
            action: "update",
            ticket
        });
        return { ticket, oldStatus, oldUserId };
    }
    catch (err) {
        Sentry.captureException(err);
    }
};
exports.default = UpdateTicketService;
