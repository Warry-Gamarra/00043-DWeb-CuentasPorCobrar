using Data.Procedures;
using Data;
using Data.Tables;
using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class TipoComprobanteService : ITipoComprobanteService
    {
        public IEnumerable<TipoComprobanteDTO> ListarTiposComprobante(bool soloHabilitados)
        {
            var lista = TC_TipoComprobante.GetAll();

            if (soloHabilitados )
            {
                lista = lista.Where(x => x.B_Habilitado);
            }

            var result = lista.Select(x => Mapper.TC_TipoComprobante_To_TipoComprobanteDTO(x));

            return result;
        }

        public Response GrabarTipoComprobante(TipoComprobanteEntity entity, SaveOption saveOption, int userID)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:

                    var grabar = new USP_I_GrabarTipoComprobante()
                    {
                        C_TipoComprobanteCod = entity.tipoComprobanteCod,
                        T_TipoComprobanteDesc = entity.tipoComprobanteDesc,
                        T_Inicial = entity.inicial,
                        UserID = userID
                    };

                    result = grabar.Execute();

                    break;

                case SaveOption.Update:

                    var actualizar = new USP_U_ActualizarTipoComprobante()
                    {
                        I_TipoComprobanteID = entity.tipoComprobanteID.Value,
                        C_TipoComprobanteCod = entity.tipoComprobanteCod,
                        T_TipoComprobanteDesc = entity.tipoComprobanteDesc,
                        T_Inicial = entity.inicial,
                        UserID = userID
                    };

                    result = actualizar.Execute();

                    break;

                default:
                    result = new ResponseData()
                    {
                        Value = false,
                        Message = "Acción no válida."
                    };

                    break;
            }

            return new Response(result);
        }

        public Response ActualizarEstadoTipoComprobante(int tipoComprobanteID, bool estaHabilitado, int userID)
        {
            ResponseData result;

            var sp = new USP_U_ActualizarEstadoTipoComprobante()
            {
                I_TipoComprobanteID = tipoComprobanteID,
                B_Habilitado = estaHabilitado,
                UserID = userID
            };

            result = sp.Execute();

            return new Response(result);
        }

        public Response EliminarEstadoTipoComprobante(int tipoComprobanteID)
        {
            ResponseData result;

            var sp = new USP_U_ActualizarEstadoTipoComprobante()
            {
                I_TipoComprobanteID = tipoComprobanteID
            };

            result = sp.Execute();

            return new Response(result);
        }
    }
}
