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
    public class SerieComprobanteService : ISerieComprobanteService
    {
        public IEnumerable<SerieComprobanteDTO> ListarSeriesComprobante(bool soloHabilitados)
        {
            var files = TC_SerieComprobante.GetAll();

            if (soloHabilitados)
            {
                files = files.Where(x => x.B_Habilitado);
            }

            var result = files.Select(x => Mapper.TC_SerieComprobante_To_SerieComprobanteDTO(x));

            return result;
        }

        public Response GrabarSerieComprobante(SerieComprobanteEntity entity, SaveOption saveOption, int userID)
        {
            ResponseData result;

            int maxNumSerie = Digiflow.MAXIMO_NUMERO_SERIE;

            if (entity.numeroSerie > maxNumSerie)
            {
                result = new ResponseData()
                {
                    Message = String.Format("El número de serie no puede ser mayor a \"{0}\".", maxNumSerie)
                };
            }
            else
            {
                switch (saveOption)
                {
                    case SaveOption.Insert:

                        if (ListarSeriesComprobante(false).Where(x => x.numeroSerie == entity.numeroSerie).Count() == 0)
                        {
                            var grabar = new USP_I_GrabarSerieComprobante()
                            {
                                I_NumeroSerie = entity.numeroSerie,
                                I_FinNumeroComprobante = entity.finNumeroComprobante,
                                I_DiasAnterioresPermitido = entity.diasAnterioresPermitido,

                            };

                            result = grabar.Execute();
                        }
                        else
                        {
                            result = new ResponseData()
                            {
                                Message = String.Format("El número de serie \"{0}\" ya se encuentra registrado en el sistema.", entity.numeroSerie)
                            };
                        }
                        
                        break;

                    case SaveOption.Update:

                        if (entity.serieID.HasValue)
                        {
                            if (ListarSeriesComprobante(false).Where(x => x.serieID != entity.serieID.Value && x.numeroSerie == entity.numeroSerie).Count() == 0)
                            {
                                var actualizar = new USP_U_ActualizarSerieComprobante()
                                {
                                    I_SerieID = entity.serieID.Value,
                                    I_NumeroSerie = entity.numeroSerie,
                                    I_FinNumeroComprobante = entity.finNumeroComprobante,
                                    I_DiasAnterioresPermitido = entity.diasAnterioresPermitido,
                                    UserID = userID
                                };

                                result = actualizar.Execute();
                            }
                            else
                            {
                                result = new ResponseData()
                                {
                                    Message = String.Format("El número de serie \"{0}\" ya se encuentra registrado en el sistema.", entity.numeroSerie)
                                };
                            }
                        }
                        else
                        {
                            result = new ResponseData()
                            {
                                Message = "Ocurrió un error al obtener los datos. Por favor recargue la página e intente la actualización nuevamente."
                            };
                        }

                        break;

                    default:
                        result = new ResponseData()
                        {
                            Value = false,
                            Message = "Acción no válida."
                        };

                        break;
                }
            }
            
            return new Response(result);
        }

        public Response ActualizarEstadoSerieComprobante(int serieID, bool estaHabilitado, int userID)
        {
            ResponseData result;

            var sp = new USP_U_ActualizarEstadoSerieComprobante()
            {
                I_SerieID = serieID,
                B_Habilitado = !estaHabilitado,
                UserID = userID
            };

            result = sp.Execute();

            return new Response(result);
        }

        public Response EliminarSerieComprobante(int serieID)
        {
            ResponseData result;

            if (!TR_Comprobante.ExistBySerie(serieID))
            {
                var sp = new USP_D_EliminarSerieComprobante()
                {
                    I_SerieID = serieID
                };

                result = sp.Execute();
            }
            else
            {
                result = new ResponseData()
                {
                    Message = "No se puede eliminar el registro seleccionado. Ya se generaron comprobantes con esta serie."
                };
            }
            
            return new Response(result);
        }
    }
}
